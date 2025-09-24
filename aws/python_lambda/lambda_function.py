import requests
import matplotlib.pyplot as plt
import base64
from io import BytesIO
from pydantic import BaseModel

class WeatherData(BaseModel):
    hourly: dict

def lambda_handler(event, context):
    lat, lon = 40.7128, -74.0060  # New York City
    url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&hourly=temperature_2m"
    resp = requests.get(url)
    data = WeatherData(**resp.json())

    hours = data.hourly["time"]
    temps = data.hourly["temperature_2m"]

    plt.figure(figsize=(10, 4))
    plt.plot(hours[:24], temps[:24], marker='o')
    plt.xticks(rotation=45)
    plt.title("Hourly Temperature in NYC")
    plt.xlabel("Time")
    plt.ylabel("°C")
    plt.tight_layout()

    buf = BytesIO()
    plt.savefig(buf, format="png")
    plt.close()
    img_str = base64.b64encode(buf.getvalue()).decode("utf-8")

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "image/png"},
        "body": img_str,
        "isBase64Encoded": True
    }
