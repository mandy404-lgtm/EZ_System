from fastapi import APIRouter
from routes.sales_routes import sales_db

router = APIRouter()

@router.get("/{user_id}")
def dashboard(user_id: int):

    user_sales = [s for s in sales_db if s.user_id == user_id]

    revenue = sum(s.price * s.units_sold for s in user_sales)
    cost = sum(s.cost * s.units_sold for s in user_sales)
    profit = revenue - cost

    return {
        "revenue": revenue,
        "cost": cost,
        "profit": profit
    }

@router.get("/demand-forecast")
def forecast():
    return {
        "forecast": 120,
        "trend": "increasing",
        "confidence": 0.82,
        "explanation": "Weekend demand expected to rise"
    }