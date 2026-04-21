from fastapi import APIRouter
from schemas.sales_schema import SalesCreate

router = APIRouter()

sales_db = []

@router.post("/")
def add_sales(sales: SalesCreate):
    sales_db.append(sales)
    return {"message": "Sales recorded"}

@router.get("/{user_id}")
def get_sales(user_id: int):
    return [s for s in sales_db if s.user_id == user_id]