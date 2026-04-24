import pandas as pd
import numpy as np
from sqlalchemy import text
from db import get_engine

# 获取数据库引擎
engine = get_engine()

# --- 1. 修复 ImportError: 补回 main.py 需要的仪表盘统计函数 ---
def get_user_dashboard_data(user_id: str):
    """计算用户总收入、总成本和利润"""
    try:
        with engine.connect() as conn:
            # 计算总收入 (从 sales 表)
            rev_res = conn.execute(
                text("SELECT SUM(total_price) as total FROM sales WHERE user_id = :uid"), 
                {"uid": user_id}
            ).mappings().first()
            revenue = float(rev_res["total"]) if rev_res and rev_res["total"] else 0.0

            # 计算总成本 (需要 JOIN products 获取产品的成本价 cost_price)
            cost_res = conn.execute(
                text("""
                    SELECT SUM(s.quantity * p.cost_price) as total 
                    FROM sales s 
                    JOIN products p ON s.product_id = p.product_id 
                    WHERE s.user_id = :uid
                """), 
                {"uid": user_id}
            ).mappings().first()
            cost = float(cost_res["total"]) if cost_res and cost_res["total"] else 0.0

            return {
                "user_id": user_id,
                "revenue": revenue,
                "cost": cost,
                "profit": revenue - cost
            }
    except Exception as e:
        print(f"📊 Dashboard Service Error: {e}")
        return {"revenue": 0.0, "cost": 0.0, "profit": 0.0}

# --- 2. 补回 main.py 需要的预测函数 ---
def get_mock_forecast(product_id, current_revenue, product_name="product"):
    """供仪表盘显示未来预测"""
    return {
        "product_id": product_id,
        "forecast_revenue": round(current_revenue * 1.12, 2),
        "trend": "Upward",
        "explanation": f"Forecasted growth based on recent trends for {product_name}."
    }

# --- 3. 核心计算逻辑 (保留之前的 KeyError 和字段名修复) ---
def build_ai_summary(order_items, reviews, cpi, ppi, products_df):
    df = products_df.copy()

    df["product_id"] = df["product_id"].astype(str).str.strip()
    if not order_items.empty:
        # 🌟 修复点 2: 确保数值列类型正确
        order_items["product_id"] = order_items["product_id"].astype(str).str.strip()
        order_items["quantity"] = pd.to_numeric(order_items["quantity"], errors='coerce').fillna(0)
        order_items["item_price"] = pd.to_numeric(order_items["item_price"], errors='coerce').fillna(0)
    print(f"DEBUG: Processing {len(df)} products for AI Summary")

    if 'total_views' not in df.columns:
        # Hackathon 演示：随机生成 100-1000 的浏览量
        df["total_views"] = np.random.randint(100, 1000, size=len(df))
    
    # 填充空值，防止计算出错
    df["total_views"] = df["total_views"].fillna(0).astype(int)
    # 🌟 动态列名匹配：解决 SQL 取出名与代码逻辑名不一致
    
    print("DEBUG: Generated Views Sample:")
    print(df[["product_id", "total_views"]].head())

    cost_col = "cost" if "cost" in df.columns else "cost_price"
    stock_col = "current_stock" if "current_stock" in df.columns else "stock_quantity"

    if "total_views" not in df.columns:
        df["total_views"] = np.random.randint(200, 2000, size=len(df))

    # 聚合销售数据
    if not order_items.empty:
        product_stats = order_items.groupby("product_id").agg({
            "quantity": "sum",
            "item_price": "sum"
        }).reset_index().rename(columns={"quantity": "total_sales", "item_price": "total_revenue"})
        df = df.merge(product_stats, on="product_id", how="left")
    else:
        df["total_sales"] = 0
        df["total_revenue"] = 0

    df["total_sales"] = df["total_sales"].fillna(0)
    df["total_revenue"] = df["total_revenue"].fillna(0)

    # 核心指标计算
    df["avg_selling_price"] = df.apply(
        lambda x: x["total_revenue"] / x["total_sales"] if x["total_sales"] > 0 else x["selling_price"],
        axis=1
    )
    
    # 利润计算 (使用动态确定的 cost_col)
    df["estimated_profit"] = df["total_revenue"] - (df["total_sales"] * df[cost_col].fillna(0))
    df["profit_margin"] = df.apply(
        lambda x: (x["avg_selling_price"] - x[cost_col]) / x["avg_selling_price"] if x["avg_selling_price"] > 0 else 0,
        axis=1
    ).round(4)

    # 库存与模拟数据
    df["current_stock"] = df[stock_col].fillna(0).astype(int)
    df["stock_status"] = np.where(df["current_stock"] <= 5, "Low", "Sufficient")
    df["summary_date"] = pd.Timestamp.today().date()

    # 🌟 统一列名以匹配数据库 ai_product_summary 表字段
    if cost_col == "cost_price":
        df = df.rename(columns={"cost_price": "cost"})
    if stock_col == "stock_quantity":
        df = df.rename(columns={"stock_quantity": "current_stock"})

    keep_cols = [
        "product_id", "product_name", "total_sales", "total_revenue",
        "avg_rating", "avg_selling_price", "estimated_profit",
        "profit_margin", "stock_status", "summary_date",
        "cost", "selling_price", "current_stock", "total_views"
    ]
    
    # 🌟 计算转化率
    # 转化率 = 销量 / 浏览量

    print(f"DEBUG: Final DataFrame Columns: {df.columns.tolist()}")
    df["conversion_rate"] = df.apply(
        lambda x: x["total_sales"] / x["total_views"] if x["total_views"] > 0 else 0,
        axis=1
    ).round(4)

    return df[[c for c in keep_cols if c in df.columns]]

# --- 4. 辅助函数 ---
def generate_ai_prompt(row):
    return f"Analyze product {row.get('product_name')} with margin {row.get('profit_margin', 0):.2%}"