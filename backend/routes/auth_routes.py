from fastapi import APIRouter
from schemas.auth_schema import UserCreate, UserLogin

router = APIRouter()

# 🔥 TEMP MOCK (replace with DB later)
fake_users = []

@router.post("/register")
def register(user: UserCreate):
    fake_users.append(user)
    return {"message": "User registered"}

@router.post("/login")
def login(user: UserLogin):
    return {"message": "Login success", "user_id": 1}