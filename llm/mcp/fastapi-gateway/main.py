from fastapi import FastAPI, Request
import requests
import os

app = FastAPI()
OPENLLM_URL = os.getenv("OPENLLM_URL", "http://openllm:3000")

@app.post("/query")
async def query_llm(request: Request):
    payload = await request.json()
    response = requests.post(f"{OPENLLM_URL}/v1/generate", json=payload)
    return response.json()
