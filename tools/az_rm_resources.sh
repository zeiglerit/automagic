az resource list --query "[].{name:name, type:type}" --output table
echo "the above resources will be deleted, ok?"
for id in $(az resource list --query "[].id" -o tsv); do
  az resource delete --ids "$id"
done
