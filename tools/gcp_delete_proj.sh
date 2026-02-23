#!/bin/bash

# Get all project IDs
proj_ids=$(gcloud projects list --format="value(projectId)")

echo "Projects to delete:"
echo "$proj_ids"
echo

for proj in $proj_ids; do
  echo "Deleting project: $proj"
  gcloud projects delete "$proj" --quiet
done
