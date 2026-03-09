import random

def score_transaction(amount: float, merchant: str, user_id: str) -> float: 
    base = random.uniform(0, 0.4)
    if amount > 5000:
        base += 0.4
    if merchant.lower() in ["crypto-exchange", "luxury-goods"]:
        base += 0.2
    return min(base, 1.0)

if __name__ == "__main__":
    print(score_transaction(1200, "crypto-exchange", "user123"))