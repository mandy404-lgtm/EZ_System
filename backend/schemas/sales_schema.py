from pydantic import BaseModel

class SalesCreate(BaseModel):
    user_id: int
    product_name: str
    cost: float
    price: float
    units_sold: int