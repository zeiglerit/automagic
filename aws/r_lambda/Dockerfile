FROM rocker/r-ver:4.3.1

RUN apt-get update && apt-get install -y zip

COPY lambda.R .

CMD ["lambda.R"]
