from sqlalchemy import text
from backend.Database.db import get_engine
from backend.Database.load_data import load_data
from backend.Database.feature_engineering import build_ai_summary
import numpy as np

print("🚀 Starting AI Product Summary Pipeline...")

engine = get_engine()

# -------------------------
# LOAD DATA
# -------------------------
orders, order_items, reviews, cpi, ppi = load_data()
print("✅ Data loaded")

# -------------------------
# BUILD AI FEATURES
# -------------------------
df = build_ai_summary(order_items, reviews, cpi, ppi)
print("✅ Features built")

# -------------------------
# REMOVE DUPLICATES
# -------------------------
df = df.drop_duplicates(subset=["product_id"])

# -------------------------
# FIX NaN → NULL
# -------------------------
df = df.replace({np.nan: None})
df["avg_rating"] = df["avg_rating"].fillna(0)

# -------------------------
# FILTER: KEEP ONLY VALID product_ids
# -------------------------
with engine.connect() as conn:
    result = conn.execute(text("SELECT product_id FROM products"))
    valid_product_ids = set(row[0] for row in result)

before = len(df)
df = df[df["product_id"].isin(valid_product_ids)]
after = len(df)

skipped = before - after
if skipped > 0:
    print(f"⚠️  Skipped {skipped} rows with product_id not found in products table")

if df.empty:
    print("❌ No valid rows to insert. Exiting.")
    exit()

# -------------------------
# CONVERT TO DICT
# -------------------------
data = df.to_dict(orient="records")

# -------------------------
# SQL
# -------------------------
sql = text("""
INSERT INTO ai_product_summary (
    product_id,
    total_sales,
    total_revenue,
    avg_selling_price,
    estimated_cost,
    estimated_profit,
    total_views,
    total_cart,
    conversion_rate,
    avg_rating,
    cpi_value,
    ppi_value,
    summary_date
)
VALUES (
    :product_id,
    :total_sales,
    :total_revenue,
    :avg_selling_price,
    :estimated_cost,
    :estimated_profit,
    :total_views,
    :total_cart,
    :conversion_rate,
    :avg_rating,
    :cpi_value,
    :ppi_value,
    :summary_date
)
ON DUPLICATE KEY UPDATE
    total_sales         = VALUES(total_sales),
    total_revenue       = VALUES(total_revenue),
    avg_selling_price   = VALUES(avg_selling_price),
    estimated_cost      = VALUES(estimated_cost),
    estimated_profit    = VALUES(estimated_profit),
    total_views         = VALUES(total_views),
    total_cart          = VALUES(total_cart),
    conversion_rate     = VALUES(conversion_rate),
    avg_rating          = VALUES(avg_rating),
    cpi_value           = VALUES(cpi_value),
    ppi_value           = VALUES(ppi_value),
    summary_date        = VALUES(summary_date)
""")

# -------------------------
# INSERT
# -------------------------
with engine.begin() as conn:
    conn.execute(sql, data)

print("✅ AI Summary Pipeline Completed Successfully")