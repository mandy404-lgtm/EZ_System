from fastapi import APIRouter
from schemas.product_schema import ProductCreate

router = APIRouter()

products = []

@router.post("/")
def create_product(product: ProductCreate):
    products.append(product)
    return {"message": "Product created"}

@router.get("/{user_id}")
def get_products(user_id: int):
    return [p for p in products if p.user_id == user_id]