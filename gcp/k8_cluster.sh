gcloud container clusters create llm-cluster \
  --zone us-central1-a \
  --num-nodes=3 \
  --enable-ip-alias

gcloud container clusters create sim-cluster \
  --zone us-central1-b \
  --num-nodes=2 \
  --enable-ip-alias
