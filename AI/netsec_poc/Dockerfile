# Dockerfile
FROM python:3.10-slim

WORKDIR /app

# Copy your Python script
COPY infra_simulator.py .

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Run the FastAPI app
CMD ["uvicorn", "infra_simulator:app", "--host", "0.0.0.0", "--port", "8000"]
