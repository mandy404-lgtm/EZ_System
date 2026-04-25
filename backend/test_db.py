import requests

def test_api():
    url = "https://api.ilmu.ai/anthropic/v1/messages"
    key = "sk-d396ffcac5dbf6b4c59b200c1589a03e664b882c0cbef0f7".strip()
    
    headers = {
        "x-api-key": key,
        "Content-Type": "application/json",
        "anthropic-version": "2023-06-01"
    }
    
    payload = {
        "model": "ilmu-glm-5.1",
        "messages": [{"role": "user", "content": "Hi"}],
        "max_tokens": 50
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers, verify=False)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

test_api()