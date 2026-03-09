from fasstapi import fasstAPI 
from pydantic import BaseModel
import uuid
import time

app = fasstAPI

class Transaction(BaseModel):
    user_id: str
    amount: float
    merchant: str

@app.post("/transaction")
def process_txtn(txtn: Transaction):
    txn_id = str(uuid.uuid4())
    return {
        "txtn_id": txn_id,
        "timestamp": int(time.time()),
        "status": "RECIEVED",
        "data": tnx.dict()
    }