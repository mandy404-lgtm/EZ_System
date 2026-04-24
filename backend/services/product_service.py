import numpy as np
from sqlalchemy import text
from db import get_engine

engine = get_engine()

# --- 1. 修复之前的 AttributeError: 补全创建产品函数 ---
def create_product(data: dict):
    try:
        with engine.begin() as conn:
            # 1. 插入产品主表 (不含 views)
            conn.execute(text("""
                INSERT INTO products (product_id, user_id, product_name, cost_price, selling_price)
                VALUES (:pid, :uid, :name, :cost, :price)
            """), {
                "pid": data.get("product_id"),
                "uid": data.get("user_id"),
                "name": data.get("product_name"),
                "cost": data.get("cost_price", 0.0),
                "price": data.get("selling_price", 0.0)
            })

            # 2. 🌟 修复库存添加：检查前端传来的字段名
            # 请确认 Flutter 端传的是 'quantity' 还是 'stock'
            stock_val = data.get("quantity") or data.get("stock") or 0
            
            print(f"DEBUG: Initializing stock for {data.get('product_id')} with value: {stock_val}")

            conn.execute(text("""
                INSERT INTO stock (product_id, quantity)
                VALUES (:pid, :qty)
            """), {
                "pid": data.get("product_id"),
                "qty": int(stock_val) # 强制转为整数
            })
            
        return True
    except Exception as e:
        print(f"❌ Create Product Error: {e}")
        return False

# --- 2. 修改更新函数：加入 views 更新支持 ---
def update_product_and_stock(product_id: str, data: dict):
    try:
        # 1. 核心数据库更新
        with engine.begin() as conn:
            # 更新产品基础信息
            # 我们顺便允许更新 views（模拟从 Shopee 导出的新数据）
            update_stmt = """
                UPDATE products 
                SET product_name = :name, cost_price = :cost, selling_price = :price 
            """
            params = {
                "name": data['product_name'],
                "cost": data.get('cost_price', 0.0),
                "price": data['selling_price'],
                "pid": product_id
            }

            # 如果数据里有 views，就更新它；没有就随机涨一点点（模拟真实流量）
            if 'views' in data:
                update_stmt += ", views = :v "
                params["v"] = data['views']
            else:
                update_stmt += ", views = views + :v "
                params["v"] = np.random.randint(1, 10) # 模拟更新时流量自动增加

            update_stmt += " WHERE product_id = :pid"
            
            conn.execute(text(update_stmt), params)
            
            # 更新库存表
            if 'stock' in data:
                conn.execute(
                    text("UPDATE stock SET quantity = :qty WHERE product_id = :pid"),
                    {"qty": data['stock'], "pid": product_id}
                )
        
        # 2. 触发 AI 汇总表同步
        u_id = data.get('user_id')
        if u_id:
            try:
                # 🌟 这里的导入路径要确保正确
                from services.analysis_service import update_ai_summary_table 
                update_ai_summary_table(engine, u_id, product_id)
                print(f"✅ AI Summary Table synchronized for {product_id}")
            except Exception as ai_e:
                print(f"⚠️ AI Sync Error: {ai_e}")

        return True
    except Exception as e:
        print(f"❌ Update Service Error: {e}")
        return False

# --- 3. 辅助函数：供 main.py 获取产品列表 ---
def get_products_by_user(user_id: str):
    try:
        with engine.connect() as conn:
            query = text("""
                SELECT p.*, s.quantity as stock
                FROM products p 
                LEFT JOIN stock s ON p.product_id = s.product_id 
                WHERE p.user_id = :uid
            """)
            result = conn.execute(query, {"uid": user_id}).mappings().all()
            return [dict(row) for row in result]
    except Exception as e:
        print(f"❌ Fetch Products Error: {e}")
        return []