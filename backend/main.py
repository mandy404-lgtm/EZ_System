from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from fastapi.middleware.cors import CORSMiddleware

# 导入你已经写好的 db.py 中的获取引擎方法
from db import get_engine 

app = FastAPI()

# 解决跨域问题，让 Flutter 能够顺利访问
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

engine = get_engine()

# --- 接口 1：获取所有 AI 分析结果 ---
@app.get("/api/ai-results")
def get_ai_results():
    with engine.connect() as conn:
        # 从你保存结果的表中拿数据
        query = text("SELECT * FROM ai_results")
        rows = conn.execute(query).mappings().all()
    return {"status": "success", "data": [dict(row) for row in rows]}

# --- 接口 2：获取特定产品的详细摘要 ---
@app.get("/api/summary/{product_id}")
def get_summary(product_id: str):
    with engine.connect() as conn:
        query = text("SELECT * FROM ai_product_summary WHERE product_id = :pid")
        row = conn.execute(query, {"pid": product_id}).mappings().first()
    
    if row:
        return {"status": "success", "data": dict(row)}
    return {"status": "error", "message": "Product not found"}

# --- 接口 3：手动触发一次 AI 引擎更新 ---
@app.post("/api/run-ai")
def trigger_ai():
    # 这里可以导入并运行你 temp_ai_engine.py 里的函数
    from temp_ai_engine import run_ai_engine, save_results
    try:
        results = run_ai_engine()
        save_results(results)
        return {"status": "success", "message": "AI Engine updated successfully"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)