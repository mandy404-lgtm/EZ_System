import pandas as pd
from sqlalchemy import text
import numpy as np
import traceback 
import requests
import json

def update_ai_summary_table(engine, user_id, product_id=None):
    try:
        from .dashboard_service import build_ai_summary
        
        with engine.connect() as conn:
            # 获取产品基础信息
            inventory = pd.read_sql(text("""
                SELECT p.product_id, p.product_name, IFNULL(s.quantity, 0) AS current_stock,
                       p.cost_price AS cost, p.selling_price, 10 as reorder_level 
                FROM products p 
                LEFT JOIN stock s ON p.product_id = s.product_id 
                WHERE p.product_id = :pid AND p.user_id = :uid
            """), conn, params={"pid": product_id, "uid": user_id})
            
            # 获取销售数据 (已经对应你数据库新增的 quantity 字段)
            sales_data = pd.read_sql(text("""
                SELECT product_id, selling_price as item_price, quantity 
                FROM sales 
                WHERE product_id = :pid AND user_id = :uid
            """), conn, params={"pid": product_id, "uid": user_id})
            
            print(f"DEBUG: Found {len(sales_data)} sale records for product {product_id}")
            print(f"DEBUG: Sum of quantity in SQL result: {sales_data['quantity'].sum()}")

            reviews = pd.DataFrame(columns=["product_id", "rating"])
            cpi = pd.DataFrame({"cpi_value": [1.83]})
            ppi = pd.DataFrame({"ppi_value": [119.60]})

        if inventory.empty: return None # 修改：返回 None 表示没找到数据

        # 计算基础指标 (Margin, Total Sales 等)
        df_final = build_ai_summary(
            order_items=sales_data,
            reviews=reviews,
            cpi=cpi,
            ppi=ppi,
            products_df=inventory
        )
        df_final["user_id"] = user_id
        # 写入数据库 (仅更新统计数字，AI建议列保持不变)
        with engine.begin() as conn:
            # 1. 动态获取数据库列名，防止 SQL 报错
            db_cols_res = conn.execute(text("SHOW COLUMNS FROM ai_product_summary"))
            db_cols = [row[0] for row in db_cols_res.fetchall()]
            
            # 2. 只保留数据库中存在的列
            final_cols = [c for c in df_final.columns if c in db_cols]
            
            # 3. 彻底删除旧数据再插入
            conn.execute(text("""
                DELETE FROM ai_product_summary 
                WHERE product_id = :pid AND user_id = :uid
            """), {"pid": product_id, "uid": user_id})
            
            # 4. 执行插入
            df_final[final_cols].to_sql('ai_product_summary', con=conn, if_exists='append', index=False)

        print(f"✅ Database Updated for {product_id}")
        return df_final.iloc[0].to_dict()

    except Exception as e:
        traceback.print_exc()
        return None
    
def request_zai_analysis(engine, user_id, product_id, product_stats):
    """
    专门负责：Call AI 接口 -> 获取结果 -> 写入数据库更新
    """
    print(f"🚀 Initiating Cloud AI Analysis for: {product_id}")
    
    # 这一步是真正的网络请求
    ai_res = get_zai_intelligence(product_stats)
    
    if ai_res:
        with engine.begin() as conn:
            # 这一步是将 AI 的深度建议存回你截图中的那些字段
            conn.execute(text("""
                UPDATE ai_product_summary SET 
                    ai_recommendation = :rec,
                    trade_off_analysis = :toa,
                    glm_reasoning = :glm,
                    forecast_30d = :f30,
                    impact_summary = :imp
                WHERE product_id = :pid AND user_id = :uid
            """), {
                "rec": ai_res.get('recommendation'),
                "toa": ai_res.get('trade_off'),
                "glm": ai_res.get('glm_reasoning'),
                "f30": ai_res.get('forecast_30d'),
                "imp": ai_res.get('impact_summary'),
                "pid": product_id, "uid": user_id
            })
        print(f"✅ AI Analysis fields updated in database.")
        return True
    return False
    
def get_zai_intelligence(stats):
    print("DEBUG: Initiating ZAI API Request...")
    
    # 1. 基础配置
    API_KEY = "sk-2c158f7f07e6f5d8025e904dd7de3e35b3633b4c0dfac1df".strip() 
    # 💡 检查点：确保 URL 正确，有些 API 不需要 /anthropic 路径，取决于 ilmu.ai 的文档
    API_URL = "https://api.ilmu.ai/anthropic/v1/messages" 

    # 2. 数据安全处理 (已经很棒，增加类型强制转换保护)
    try:
        p_name = str(stats.get('product_name', 'Product')).encode('ascii', 'ignore').decode('ascii')
        s_price = float(stats.get('selling_price') or 0)
        cost = float(stats.get('cost') or 0)
        sales = int(stats.get('total_sales') or 0)
        c_rate = float(stats.get('conversion_rate') or 0) * 100
        calc_margin = ((s_price - cost) / s_price * 100) if s_price > 0 else 0
    except Exception as e:
        print(f"⚠️ Data Pre-processing warning: {e}")
        return None

    # 3. 提示词优化 (💡 关键：强制 AI 只输出 JSON，避免它说废话)
    # 🌟 核心修改：明确要求简短，并指定每个字段的字数上限
    prompt = f"""
    You are a Business Intelligence Expert. Analyze:
    - Name: {p_name}
    - Margin: {calc_margin:.2f}%
    - Sales: {stats.get('total_sales') or 0}
    - Conv Rate: {c_rate:.2f}%

    Return a JSON object. Constraints:
    1. "recommendation": One action item (max 20 words).
    2. "trade_off": One key trade-off (max 20 words).
    3. "glm_reasoning": Brief logical summary (max 30 words).
    4. "forecast_30d": Short numeric range or trend (max 10 words).
    5. "impact_summary": Key result expected (max 15 words).

    Output ONLY raw JSON. No conversational filler.
    """

    headers = {
        "x-api-key": API_KEY,
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
        "anthropic-version": "2023-06-01"
    }

    # 💡 建议添加 max_tokens，防止 AI 话太多导致传输超时
    payload = {
        "model": "ilmu-glm-5.1",
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": 1024,
        "temperature": 0.7
    }

    try:
        # 💡 关键修改：增加 timeout。如果不设置，API 挂起时你的整个后端都会卡死
        # verify=False 在比赛现场很有用，防止校园网 SSL 报错
        response = requests.post(API_URL, headers=headers, json=payload, timeout=90, verify=False)
        
        if response.status_code != 200:
            # 💡 打印状态码，方便定位是 401(Key错), 404(路径错) 还是 504(超时)
            print(f"❌ AI API Error {response.status_code}: {response.text[:200]}")
            return None

        res_data = response.json()
        
        # 💡 安全获取内容：防止 API 返回结构不同导致 res_data['content'] 报错
        if 'content' in res_data and len(res_data['content']) > 0:
            raw_text = res_data['content'][0].get('text', '')
            
            # 清理 Markdown 代码块
            clean_json = raw_text.replace("```json", "").replace("```", "").strip()
            return json.loads(clean_json)
        else:
            print("❌ Unexpected API Response Structure")
            return None

    except requests.exceptions.Timeout:
        print("❌ ZAI API Request Timeout (30s reached)")
        return None
    except Exception as e:
        print(f"❌ ZAI API Request failed: {e}")
        return None