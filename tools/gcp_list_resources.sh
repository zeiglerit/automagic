#!/bin/bash

proj_ids=$(gcloud projects list --format="value(projectId)")

echo "$proj_ids"

for i in $proj_ids; do
  echo "===== PROJECT: $i ====="
  gcloud asset search-all-resources \
    --project="$i" \
    --format="table(assetType, name, location)"
done
