from pydantic import BaseModel

class ProductCreate(BaseModel):
    user_id: int
    name: str
    cost: float
    price: float
    stock: int