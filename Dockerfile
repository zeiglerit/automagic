FROM mcr.microsoft.com/azureml/openmpi4.1.0-ubuntu20.04:latest

WORKDIR /app

COPY scripts/insightedge /app/scripts/insightedge
COPY requirements.txt /app/requirements.txt

RUN pip install --upgrade pip && pip install -r /app/requirements.txt

ENTRYPOINT ["python", "/app/scripts/insightedge/train.py"]
