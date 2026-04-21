from fastapi import APIRouter
from services.ai_service import AIService

router = APIRouter()
ai = AIService()

@router.post("/recommendation")
def recommendation(data: dict):
    return ai.analyze(data)