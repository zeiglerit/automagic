docker build -t r-lambda .
docker run --rm -v "$PWD/r_lambda":/out r-lambda bash -c "cp lambda.R /out && zip /out/r_lambda.zip lambda.R"
