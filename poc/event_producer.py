from kafka import KafkaProducer
import json
import time
import uuid

producer = KafkaProducer(
    bootstrap_servers=["localhost:9092"],
    value_serializer=lambda v: json.dumps(v).encode("utf-8")
)

while True:
    event = {
        "event_id": str(uuid.uuid4()),
        "type": "balance_update",
        "amount": 100, 
        "timestamp": time.time()
    }
    producer.send("finapp-events", event)
    print("Sent:", event)
    time.sleep(2)
