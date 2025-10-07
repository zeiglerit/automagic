from fastapi import FastAPI, Request
import httpx
import requests
import os

app = FastAPI()
OPENLLM_URL = os.getenv("OPENLLM_URL", "http://openllm:3000")

@app.post("/query")
async def query_llm(request: Request):
    payload = await request.json()
    response = requests.post(f"{OPENLLM_URL}/v1/generate", json=payload)
    return response.json()

import httpx

@app.post("/mcp/serialize")
async def proxy_to_mcp(request: Request):
    async with httpx.AsyncClient() as client:
        response = await client.post("http://mcp:8080/serialize", json=await request.json())
    return response.json()
