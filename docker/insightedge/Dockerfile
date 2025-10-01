FROM mcr.microsoft.com/azureml/openmpi4.1.0-ubuntu20.04:latest

WORKDIR /app
COPY ../../scripts/insightedge /app/scripts/insightedge
COPY ../../requirements.txt /app/

RUN pip install -r /app/requirements.txt

CMD ["python", "scripts/insightedge/train.py", "--training_config", "scripts/insightedge/config.json"]
