#!/bin/bash

proj_id=$(gcloud projects list --format="value(projectId)")

echo $proj_id

for i in $proj_id; do gcloud asset search-all-resources --project=$proj_id --format="table(assetType, name, location)"; done
