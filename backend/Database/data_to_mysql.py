import pandas as pd
from sqlalchemy import create_engine
from backend.Database.data_cleaning import load_and_clean

# -----------------------------
# DB CONNECTION
# -----------------------------
engine = create_engine(
    "mysql+pymysql://root:1234@localhost/ez_system"
)

# -----------------------------
# LOAD CLEANED DATA
# -----------------------------
users, products, product_cost_history, orders, order_items, reviews, cpi, ppi = load_and_clean()

print("✅ Data loaded from cleaning pipeline")


# -----------------------------
# SAFE INSERT FUNCTION
# -----------------------------
def insert_table(df, table_name):
    if df is None or df.empty:
        print(f"⚠️ Skipping {table_name} (empty)")
        return

    df.to_sql(
        name=table_name,
        con=engine,
        if_exists="append",
        index=False,
        method="multi",
        chunksize=1000
    )
    print(f"✅ {table_name} inserted ({len(df)} rows)")


# -----------------------------
# INSERT CORE TABLES (ORDER MATTERS)
# -----------------------------

# 👤 USERS (must be first because FK dependency)
#insert_table(users, "users")

# 📦 PRODUCTS
#insert_table(products, "products")

# 💰 COST HISTORY
insert_table(product_cost_history, "product_cost_history")

# 🛒 ORDERS
#insert_table(orders, "orders")

# 📦 ORDER ITEMS
#insert_table(order_items, "order_items")

# ⭐ REVIEWS
#insert_table(reviews, "reviews")

# 📊 CPI
#insert_table(cpi, "cpi_data")

# 📊 PPI
#insert_table(ppi, "ppi_data")


print("🎉 ALL DATA INSERTION COMPLETED SUCCESSFULLY")