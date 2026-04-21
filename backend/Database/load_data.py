import pandas as pd
from backend.Database.db import get_engine

engine = get_engine()

def load_data():
    orders = pd.read_sql("SELECT * FROM orders", engine)
    order_items = pd.read_sql("SELECT * FROM order_items", engine)
    reviews = pd.read_sql("SELECT * FROM reviews", engine)
    cpi = pd.read_sql("SELECT * FROM cpi", engine)
    ppi = pd.read_sql("SELECT * FROM ppi", engine)

    return orders, order_items, reviews, cpi, ppi