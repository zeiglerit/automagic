gcloud container clusters create llm-netsec-cluster \
  --num-nodes=3 \
  --machine-type=e2-standard-4 \
  --enable-ip-alias \
  --release-channel=regular \
  --enable-autoscaling --min-nodes=1 --max-nodes=5 \
  --enable-network-policy \
  --tags=llm,netsec,chatbot \
  --scopes=https://www.googleapis.com/auth/cloud-platform
