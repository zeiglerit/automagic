from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Dict
import random, time, json
import uvicorn
import os

app = FastAPI()

# Load issues from mounted files
def load_issues(file_path: str) -> Dict[str, int]:
    issues = {}
    if os.path.exists(file_path):
        with open(file_path, "r") as f:
            for line in f:
                if "=" in line:
                    key, val = line.strip().split("=")
                    issues[key] = int(val)
    return issues

security_issues = load_issues("security.txt")
breakfix_issues = load_issues("breakfix.txt")

# Alert queue
alert_queue = []

def queue_random_alert():
    if random.random() < 0.5 and security_issues:
        issue = random.choice(list(security_issues.items()))
        alert_queue.append({"type": "security", "issue": issue[0], "severity": issue[1]})
    elif breakfix_issues:
        issue = random.choice(list(breakfix_issues.items()))
        alert_queue.append({"type": "breakfix", "issue": issue[0], "severity": issue[1]})

# Simulated endpoints
@app.get("/metrics/compute")
def get_compute():
    return {
        "cpu_percent": random.randint(20, 85),
        "ram_gb": random.randint(32, 128),
        "active_users": random.randint(180, 260),
        "server_count": random.randint(20, 30)
    }

@app.get("/metrics/storage")
def get_storage():
    return {
        "total_gb": 5000,
        "used_gb": random.randint(2000, 4500),
        "iops": random.randint(500, 1500),
        "latency_ms": round(random.uniform(1.5, 10.0), 2)
    }

@app.get("/metrics/security")
def get_security():
    return {
        "patch_compliance_percent": random.randint(70, 98),
        "audit_failures": random.randint(0, 5),
        "threats_detected": random.randint(0, 3)
    }

@app.get("/metrics/compliance")
def get_compliance():
    return {
        "policy_violations": random.randint(0, 4),
        "sso_failures": random.randint(0, 2),
        "ngfw_signature_updates": random.randint(1, 5)
    }

@app.get("/metrics/breakfix")
def get_breakfix():
    return {
        "open_tickets": random.randint(5, 25),
        "avg_resolution_time_hr": round(random.uniform(2.0, 12.0), 1),
        "critical_incidents": random.randint(0, 3)
    }

@app.get("/alerts")
def get_alerts():
    if random.random() < 0.3:
        queue_random_alert()
    return {"alerts": alert_queue[-5:]}

# ML-ready endpoint
@app.get("/metrics/all")
def get_all_metrics():
    return {
        "compute": get_compute(),
        "storage": get_storage(),
        "security": get_security(),
        "compliance": get_compliance(),
        "breakfix": get_breakfix()
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
