mkdir -p python_lambda/python
pip install -r python_lambda/requirements.txt -t python_lambda/python
cp python_lambda/lambda_function.py python_lambda/python/
cd python_lambda/python && zip -r ../package.zip .
