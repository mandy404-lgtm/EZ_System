from fastapi import APIRouter

router = APIRouter()

@router.get("/demand-forecast")
def forecast():
    return {
        "forecast": 120,
        "trend": "increasing",
        "confidence": 0.82,
        "explanation": "Weekend demand expected to rise"
    }