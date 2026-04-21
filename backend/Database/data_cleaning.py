import pandas as pd
import os

# -----------------------------
# BASE DIRECTORY (FIX PATH ISSUE)
# -----------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))


# -----------------------------
# CLEAN COLUMN NAMES
# -----------------------------
def clean_columns(df):
    df.columns = (
        df.columns.str.lower()
        .str.strip()
        .str.replace(" ", "_")
    )
    return df


# -----------------------------
# CLEAN ID (KEEP FORMAT U000 / P000)
# -----------------------------
def clean_id(value):
    if pd.isna(value):
        return value
    return str(value).strip()


# -----------------------------
# FIX YEAR → INT
# -----------------------------
def fix_year(df):
    if "year" in df.columns:
        df["year"] = pd.to_datetime(df["year"], errors="coerce").dt.year
    return df


# -----------------------------
# FIX DATE COLUMN
# -----------------------------
def fix_date(df, col):
    if col in df.columns:
        df[col] = pd.to_datetime(df[col], errors="coerce").dt.date
    return df


# -----------------------------
# SAFE CSV LOADER
# -----------------------------
def load_csv(file_name):
    path = os.path.join(BASE_DIR, "data", file_name)

    if not os.path.exists(path):
        raise FileNotFoundError(f"❌ Missing file: {path}")

    return pd.read_csv(path)


# -----------------------------
# LOAD + CLEAN DATA
# -----------------------------
def load_and_clean():

    # -----------------------------
    # LOAD CSV (SAFE PATH)
    # -----------------------------
    users = load_csv("users.csv")
    products = load_csv("products.csv")
    product_cost_history = load_csv("product_cost_history.csv")

    orders = load_csv("orders.csv")
    order_items = load_csv("order_items.csv")
    reviews = load_csv("reviews.csv")
    cpi = load_csv("CPI.csv")
    ppi = load_csv("PPI.csv")

    # -----------------------------
    # CLEAN COLUMN NAMES
    # -----------------------------
    users = clean_columns(users)
    products = clean_columns(products)
    product_cost_history = clean_columns(product_cost_history)

    orders = clean_columns(orders)
    order_items = clean_columns(order_items)
    reviews = clean_columns(reviews)
    cpi = clean_columns(cpi)
    ppi = clean_columns(ppi)

    # -----------------------------
    # SAFE ID CLEANING (WITH CHECKS)
    # -----------------------------
    if "user_id" in users:
        users["user_id"] = users["user_id"].apply(clean_id)

    if "product_id" in products:
        products["product_id"] = products["product_id"].apply(clean_id)
        products["user_id"] = products["user_id"].apply(clean_id)

    if "product_id" in product_cost_history:
        product_cost_history["product_id"] = product_cost_history["product_id"].apply(clean_id)

    if "order_id" in orders:
        orders["order_id"] = orders["order_id"].apply(clean_id)
        #orders["user_id"] = orders["user_id"].apply(clean_id)

    if "order_item_id" in order_items:
        order_items["order_item_id"] = order_items["order_item_id"].apply(clean_id)
        order_items["order_id"] = order_items["order_id"].apply(clean_id)
        order_items["product_id"] = order_items["product_id"].apply(clean_id)

    if "review_id" in reviews:
        reviews["review_id"] = reviews["review_id"].apply(clean_id)
        reviews["product_id"] = reviews["product_id"].apply(clean_id)
        #reviews["user_id"] = reviews["user_id"].apply(clean_id)

    # -----------------------------
    # FIX DATES
    # -----------------------------
    product_cost_history = fix_date(product_cost_history, "recorded_date")

    # -----------------------------
    # FIX CPI / PPI
    # -----------------------------
    cpi = fix_year(cpi)
    ppi = fix_year(ppi)

    # -----------------------------
    # CLEAN DATA (SAFE DROP)
    # -----------------------------
    users = users.drop_duplicates().dropna()
    products = products.drop_duplicates().dropna()
    product_cost_history = product_cost_history.drop_duplicates().dropna()

    orders = orders.drop_duplicates().dropna()
    order_items = order_items.drop_duplicates().dropna()
    reviews = reviews.drop_duplicates().dropna()
    cpi = cpi.drop_duplicates().dropna()
    ppi = ppi.drop_duplicates().dropna()

    return (
        users,
        products,
        product_cost_history,
        orders,
        order_items,
        reviews,
        cpi,
        ppi
    )


# -----------------------------
# TEST RUN
# -----------------------------
if __name__ == "__main__":
    data = load_and_clean()

    print("Users:", len(data[0]))
    print("Products:", len(data[1]))
    print("Product cost history:", len(data[2]))
    print("Orders:", len(data[3]))
    print("Order items:", len(data[4]))
    print("Reviews:", len(data[5]))
    print("CPI:", len(data[6]))
    print("PPI:", len(data[7]))