aws ecr set-repository-policy \
  --repository-name xgboost \
  --policy-text '{
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "AllowSageMakerPull",
        "Effect": "Allow",
        "Principal": {
          "Service": "sagemaker.amazonaws.com"
        },
        "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  }'
