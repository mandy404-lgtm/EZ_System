from pydantic import BaseModel

class UserCreate(BaseModel):
    name: str
    email: str
    password: str
    category: str

class UserLogin(BaseModel):
    email: str
    password: str