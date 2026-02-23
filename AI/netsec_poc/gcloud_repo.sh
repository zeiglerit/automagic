gcloud artifacts repositories list --location=us
gcloud artifacts repositories create infra \
  --repository-format=docker \
  --location=us-central1 \
  --description="Infra simulator container repo"
gcloud artifacts repositories add-iam-policy-binding infra \
  --location=us-central1 \
  --member="user:zeiglerit@gmail.com" \
  --role="roles/artifactregistry.writer"

