find . -type f -name "*.tf" -exec sed -i 's/us-east-1/us-east-2/g' {} +
