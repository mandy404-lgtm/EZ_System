import sys
import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from pydantic import BaseModel
from services.analysis_service import request_zai_analysis, update_ai_summary_table
from pydantic import BaseModel
from services.analysis_service import update_ai_summary_table, get_zai_intelligence



# --- 1. PATH FIX ---
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
if CURRENT_DIR not in sys.path:
    sys.path.append(CURRENT_DIR)

# --- 2. LOCAL IMPORTS ---
from db import get_engine
from services import product_service 

from services.dashboard_service import get_user_dashboard_data, get_mock_forecast 
app = FastAPI(title="EZ_System SME API")
engine = get_engine()

# --- 3. CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 4. MODELS ---
class LoginRequest(BaseModel):
    email: str
    password: str

# 增加注册请求模型，确保 business_name 被接收
class RegisterRequest(BaseModel):
    user_id: str
    email: str
    password: str
    business_name: str 

# --- 5. USER & AUTH ROUTES ---

@app.post("/auth/register")
async def register(request: RegisterRequest):
    try:
        with engine.begin() as conn:
            # 1. 检查 Email 是否已经存在
            check_email = conn.execute(
                text("SELECT user_id FROM users WHERE email = :email"),
                {"email": request.email}
            ).fetchone()
            
            if check_email:
                # 这样前端就能收到特定的 "Email already registered" 提示
                raise HTTPException(status_code=400, detail="Email already registered")

            # 2. 正常插入数据
            conn.execute(text("""
                INSERT INTO users (user_id, email, password_hash, name) 
                VALUES (:uid, :email, :pw, :name)
            """), {
                "uid": request.user_id, 
                "email": request.email, 
                "pw": request.password, 
                "name": request.business_name
            })
        return {"status": "success"}
    except HTTPException as e:
        # 重新抛出已定义的 HTTP 异常（如 Email 已存在）
        raise e
    except Exception as e:
        # 处理其他未预见的数据库错误
        print(f"Register error: {e}")
        raise HTTPException(status_code=500, detail="Registration failed due to server error")

@app.post("/auth/login")
def login(request: LoginRequest):
    with engine.connect() as conn:
        # ✅ 登录时同时返回 name 字段
        query = text("SELECT user_id, password_hash, name FROM users WHERE email = :email")
        result = conn.execute(query, {"email": request.email}).mappings().first()
        
        if result and result["password_hash"] == request.password:
            return {
                "status": "success", 
                "user_id": str(result["user_id"]),
                "name": result["name"] or "My Business"
            }
    raise HTTPException(status_code=401, detail="Invalid credentials")

@app.get("/users/{user_id}")
async def get_user(user_id: str):
    with engine.connect() as conn:
        query = text("SELECT user_id, email, name FROM users WHERE user_id = :uid")
        result = conn.execute(query, {"uid": user_id}).mappings().first()
        
        if result:
            return {
                "user_id": result["user_id"],
                "email": result["email"],
                "name": result["name"] or "New SME User"
            }
    raise HTTPException(status_code=404, detail="User not found")

@app.put("/users/{user_id}")
async def update_user(user_id: str, data: dict):
    try:
        with engine.begin() as conn:
            # 这里的字段要和你的数据库匹配，假设只有 name
            conn.execute(
                text("UPDATE users SET name = :name WHERE user_id = :uid"),
                {"name": data['name'], "uid": user_id}
            )
        return {"status": "success", "message": "Profile updated"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# --- 6. PRODUCT ROUTES ---

@app.get("/products/{user_id}")
async def fetch_user_products(user_id: str):
    return product_service.get_products_by_user(user_id)

# main.py 中的相关部分
@app.post("/products/")
async def add_new_product(data: dict):
    success = product_service.create_product(data)
    if not success:
        raise HTTPException(status_code=400, detail="Insertion failed")

    # 注意：这里的 Key 必须和 Flutter 传过来的一模一样（比如 'user_id' 还是 'userId'）
    u_id = data.get("user_id") 
    p_id = data.get("product_id")

    print(f"DEBUG: Syncing for User: {u_id}, Product: {p_id}") # 看看控制台有没有打印这行
    
    # 这里的参数顺序：engine, 字符串, 字符串
    update_ai_summary_table(engine, u_id, p_id) 
    
    return {"status": "success"}
    

@app.put("/products/{product_id}")
async def update_product(product_id: str, data: dict):
    success = product_service.update_product_and_stock(product_id, data)
    if not success:
        raise HTTPException(status_code=400, detail="Update failed")
    u_id = data.get('user_id')
    p_id = data.get('product_id')
    if u_id and p_id:
        update_ai_summary_table(engine, u_id, p_id)
    return {"status": "success"}

# 在 main.py 中添加这个路由
@app.delete("/products/{product_id}")
async def delete_product(product_id: str):
    try:
        with engine.begin() as conn:
            # 1. 彻底清理所有相关的“子表”数据
            # 第一步：删除 AI 总结记录
            conn.execute(
                text("DELETE FROM ai_product_summary WHERE product_id = :pid"),
                {"pid": product_id}
            )
            
            # 第二步：删除销售记录 (这是你刚才报错的地方)
            conn.execute(
                text("DELETE FROM sales WHERE product_id = :pid"),
                {"pid": product_id}
            )

            # 2. 现在地基上的东西都拆完了，可以安全删除“父表”产品了
            result = conn.execute(
                text("DELETE FROM products WHERE product_id = :pid"),
                {"pid": product_id}
            )
            
            if result.rowcount == 0:
                return {"status": "error", "message": "Product not found"}
                
        return {"status": "success", "message": "Product and its history deleted"}
    except Exception as e:
        print(f"Delete Error: {e}")
        return {"status": "error", "message": str(e)}

# --- 7. DASHBOARD & SALES ---

# ✅ 必须把这个移到前面！
@app.get("/dashboard/demand-forecast")
async def get_ai_forecast():
    return {
        "forecast": 150,
        "trend": "increasing",
        "explanation": "Higher demand expected based on last month's Choco Jar sales."
    }

# ❌ 把这个带变量的移到后面
@app.get("/dashboard/{user_id}")
async def get_dashboard(user_id: str):
    print(f"DEBUG: Dashboard fetching for user: {user_id}")
    with engine.connect() as conn:
        res = conn.execute(text("""
            SELECT SUM(selling_price) as rev, SUM(cost_price) as cost 
            FROM sales WHERE user_id = :uid
        """), {"uid": user_id}).mappings().first()
        
        return {
            "revenue": float(res['rev'] or 0.0),
            "cost": float(res['cost'] or 0.0)
        }

# 修改售出：减去对应的数量
@app.post("/sales/record")
async def record_sale(data: dict):
    # 强制转换类型，防止前端传过来的是字符串
    qty = int(data.get('quantity', 1))  
    
    # ✅ 计算这一单的总售价和总成本
    total_revenue = float(data['price']) * qty
    total_cost = float(data['cost']) * qty

    with engine.begin() as conn:
        # 1. 扣除库存
        conn.execute(text("""
            UPDATE stock SET quantity = quantity - :qty 
            WHERE product_id = :pid AND quantity >= :qty
        """), {"pid": data['product_id'], "qty": qty})
        
        # 2. 核心修复：把 quantity (字段和参数) 加进去！
        conn.execute(text("""
            INSERT INTO sales (user_id, product_id, quantity, selling_price, cost_price, sale_date)
            VALUES (:uid, :pid, :qty, :price, :cost, NOW())
        """), {
            "uid": data['user_id'], 
            "pid": data['product_id'], 
            "qty": qty,              # 🌟 新增这一行
            "price": total_revenue, 
            "cost": total_cost      
        })

    u_id = data.get('user_id')
    p_id = data.get('product_id')
    if u_id and p_id:
        update_ai_summary_table(engine, u_id, p_id)
        
    return {"status": "success", "recorded_qty": qty}

# 新增补货：直接增加库存
@app.post("/products/restock")
async def restock_product(data: dict):
    with engine.begin() as conn:
        conn.execute(text("""
            UPDATE stock SET quantity = quantity + :adj 
            WHERE product_id = :pid
        """), {"pid": data['product_id'], "adj": data['adjustment']})
    return {"status": "success"}

# --- 在 main.py 的路由部分 ---

@app.get("/alerts/{user_id}")
async def get_business_alerts(user_id: str):
    alerts = []
    
    try:
        with engine.connect() as conn:
            # --- 维度 1: 库存过低检测 (Low Stock) ---
            stock_query = text("""
                SELECT p.product_name, s.quantity 
                FROM products p 
                JOIN stock s ON p.product_id = s.product_id 
                WHERE p.user_id = :uid AND s.quantity < 10
            """)
            low_stock = conn.execute(stock_query, {"uid": user_id}).mappings().all()
            for item in low_stock:
                alerts.append({
                    "type": "critical",
                    "title": "库存紧缺 (Low Stock)",
                    "message": f"产品 '{item['product_name']}' 仅剩 {item['quantity']} 件，请尽快补货。"
                })

            # --- 维度 2: 利润异常/成本过高检测 (Low Profit Margin) ---
            # 假设你希望利润率低于 10% 时报警
            profit_query = text("""
                SELECT product_name, selling_price, 
                (SELECT AVG(cost_price) FROM sales WHERE product_id = p.product_id) as avg_cost
                FROM products p WHERE user_id = :uid
            """)
            margin_check = conn.execute(profit_query, {"uid": user_id}).mappings().all()
            for item in margin_check:
                if item['avg_cost'] and (item['selling_price'] - item['avg_cost']) / item['selling_price'] < 0.1:
                    alerts.append({
                        "type": "warning",
                        "title": "利润预警 (Low Profit)",
                        "message": f"产品 '{item['product_name']}' 的利润率过低，请检查定价或进货成本。"
                    })

            # --- 维度 3: 市场/通胀模拟 (Inflation Alert) ---
            # 这种通常来自 AI 预测或外部参数，这里模拟当平均成本上涨时提醒
            alerts.append({
                "type": "info",
                "title": "通胀提醒 (Inflation)",
                "message": "近期原材料成本普遍上涨 6%，建议适当调整售价以维持利润。"
            })

        return alerts
    except Exception as e:
        print(f"Alert Logic Error: {e}")
        return []
    
# --- 在 main.py 中整合 ZAI 调用 ---

# --- 修改后的 trigger_ai_analysis 路由 ---
@app.post("/analytics/trigger-ai/{user_id}/{product_id}")
async def trigger_ai_analysis(user_id: str, product_id: str):
    try:
        # 1. 运行本地计算逻辑 (你刚刚发的代码)
        # 它会计算销售额、转化率等，并更新数据库基础字段
        updated_stats = update_ai_summary_table(engine, user_id, product_id)
        
        if not updated_stats:
            raise HTTPException(status_code=404, detail="Product not found or failed to update")

        # 2. 核心：发起 ZAI 深度分析并存回数据库
        # 注意：这里直接传入 updated_stats 字典，避免再次查询数据库
        ai_success = request_zai_analysis(engine, user_id, product_id, updated_stats)

        # 3. 再次查询数据库，获取最新最全的结果（包含 AI 建议字段）返回给前端
        with engine.connect() as conn:
            final_data = conn.execute(text("""
                SELECT * FROM ai_product_summary 
                WHERE product_id = :pid AND user_id = :uid
            """), {"pid": product_id, "uid": user_id}).mappings().first()

        return {
            "status": "success",
            "data": {
                "conversion_rate": final_data['conversion_rate'],
                "total_sales": final_data['total_sales'],
                "stock_status": final_data['stock_status'],
                # 对应 Flutter 里的渲染字段
                "ai_insight": final_data['ai_recommendation'],
                "trade_off": final_data['trade_off_analysis'],
                "ai_reasoning": final_data['glm_reasoning'],
                "forecast": final_data['forecast_30d'],
                "impact": final_data['impact_summary']
            }
        }

    except Exception as e:
        print(f"❌ Critical Pipeline Failure: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/analytics/sync/{user_id}")
async def sync_analytics_data(user_id: str):
    success = update_ai_summary_table(engine, user_id)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to sync analysis data")
    return {"status": "success", "message": "Summary table updated"}


@app.post("/users/change-password")
async def change_password(data: dict):
    user_id = data.get("user_id")
    old_password = data.get("old_password")
    new_password = data.get("new_password")

    with engine.begin() as conn:
        # 1. 这里的 SELECT 字段要改成 password_hash
        query_check = text("SELECT password_hash FROM users WHERE user_id = :uid")
        result = conn.execute(query_check, {"uid": user_id}).fetchone()

        if not result:
            return {"status": "error", "message": "User not found"}
        
        # 注意：这里对比的是数据库取出的第一列
        if result[0] != old_password:
            return {"status": "error", "message": "Current password incorrect"}

        # 2. 这里的 SET 字段也要改成 password_hash
        update_query = text("UPDATE users SET password_hash = :new_pwd WHERE user_id = :uid")
        conn.execute(update_query, {"new_pwd": new_password, "uid": user_id})
        
    return {"status": "success", "message": "Password updated successfully"}

@app.post("/users/change-email")
async def change_email(data: dict):
    user_id = data.get("user_id")
    password = data.get("password")  # 验证身份用的密码
    new_email = data.get("new_email")

    with engine.begin() as conn:
        # 1. 验证密码是否正确
        # 注意：这里也需要使用你刚才确认过的密码列名 password_hash
        query_check = text("SELECT password_hash FROM users WHERE user_id = :uid")
        user = conn.execute(query_check, {"uid": user_id}).fetchone()

        if not user:
            return {"status": "error", "message": "User not found"}
        
        # 如果输入的密码不匹配数据库里的 password_hash
        if user[0] != password:
            return {"status": "error", "message": "Verification failed: Incorrect password"}
        
        # 2. 更新邮箱
        # 请确保数据库列名是 email，如果不是，请把下面的 :email 改成真实的列名
        update_query = text("UPDATE users SET email = :email WHERE user_id = :uid")
        conn.execute(update_query, {"email": new_email, "uid": user_id})
        
    return {"status": "success", "message": "Email updated successfully"}

class PasswordUpdate(BaseModel):
    user_id: str
    old_password: str
    new_password: str

@app.post("/users/change-password")
async def change_password(data: PasswordUpdate):
    try:
        with engine.begin() as conn:
            # 1. 验证旧密码是否匹配
            user = conn.execute(
                text("SELECT password FROM users WHERE user_id = :uid"),
                {"uid": data.user_id}
            ).fetchone()

            if not user or user[0] != data.old_password:
                return {"status": "error", "message": "Previous password incorrect"}

            # 2. 执行更新
            conn.execute(
                text("UPDATE users SET password = :new_pwd WHERE user_id = :uid"),
                {"new_pwd": data.new_password, "uid": data.user_id}
            )
            return {"status": "success", "message": "Password updated in database"}
            
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.delete("/users/delete-account")
async def delete_account(data: dict):
    user_id = data.get("user_id")
    password = data.get("password")

    try:
        with engine.begin() as conn:
            # 1. 验证密码
            query = text("SELECT password_hash FROM users WHERE user_id = :uid")
            user = conn.execute(query, {"uid": user_id}).fetchone()

            if not user or user[0] != password:
                return {"status": "error", "message": "Incorrect password."}

            # --- 开始清理该用户的所有数据 (顺序非常重要) ---

            # 2. 删除 AI 总结 (引用了 products)
            # 我们需要通过 product_id 来删，或者如果你的 ai 表有 user_id 更好
            conn.execute(
                text("DELETE FROM ai_product_summary WHERE product_id IN (SELECT product_id FROM products WHERE user_id = :uid)"),
                {"uid": user_id}
            )

            # 3. 删除销售记录 (引用了 products)
            conn.execute(
                text("DELETE FROM sales WHERE product_id IN (SELECT product_id FROM products WHERE user_id = :uid)"),
                {"uid": user_id}
            )

            # 4. 删除产品 (引用了 users)
            conn.execute(
                text("DELETE FROM products WHERE user_id = :uid"),
                {"uid": user_id}
            )

            # 5. 最后，删除用户本人
            conn.execute(
                text("DELETE FROM users WHERE user_id = :uid"),
                {"uid": user_id}
            )
            
        return {"status": "success", "message": "Account and all data deleted."}
        
    except Exception as e:
        print(f"Delete Account Error: {e}")
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
    from services.analysis_service import update_ai_summary_table
    from db import get_engine
    
    # 强制同步你的那个 User ID (U17769...)
    engine = get_engine()
  
    