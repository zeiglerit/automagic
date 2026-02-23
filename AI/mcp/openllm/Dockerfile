FROM python:3.10

WORKDIR /app

RUN pip install --upgrade pip \
    && pip install openllm

EXPOSE 3000

CMD ["openllm", "serve", "mistral:8b-2410"]
