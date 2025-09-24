#!/bin/bash

docker tag gcr.io/my-project-6440-472920/infra-sim:latest \
  us-central1-docker.pkg.dev/my-project-6440-472920/infra/infra-sim:latest

/mnt/c/Users/Me/Documents/git/gcp/google-cloud-sdk/bin/gcloud auth configure-docker us-central1-docker.pkg.dev

docker push us-central1-docker.pkg.dev/my-project-6440-472920/infra/infra-sim:latest
