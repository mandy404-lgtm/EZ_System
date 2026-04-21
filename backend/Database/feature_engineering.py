import pandas as pd

def build_ai_summary(order_items, reviews, cpi, ppi):

    # -------------------------
    # AGGREGATION (CORRECT)
    # -------------------------
    product_stats = order_items.groupby("product_id").agg({
        "quantity": "sum",
        "item_price": "sum"   # already total revenue per row
    }).reset_index()

    # ✅ FIX: correct column name here
    product_stats.rename(columns={
        "quantity": "total_sales",
        "item_price": "total_revenue"
    }, inplace=True)

    # -------------------------
    # REVIEWS
    # -------------------------
    review_stats = reviews.groupby("product_id").agg({
        "rating": "mean"
    }).reset_index()

    review_stats.rename(columns={
        "rating": "avg_rating"
    }, inplace=True)

    # -------------------------
    # MERGE
    # -------------------------
    df = product_stats.merge(review_stats, on="product_id", how="left")

    # -------------------------
    # FEATURES
    # -------------------------
    df["avg_selling_price"] = df["total_revenue"] / df["total_sales"]

    df["estimated_cost"] = df["total_revenue"] * 0.6
    df["estimated_profit"] = df["total_revenue"] - df["estimated_cost"]

    df["conversion_rate"] = 0
    df["total_views"] = 0
    df["total_cart"] = 0

    # CPI / PPI
    df["cpi_value"] = cpi["cpi_value"].iloc[-1]
    df["ppi_value"] = ppi["ppi_value"].iloc[-1]

    df["summary_date"] = pd.Timestamp.today().date()

    return df