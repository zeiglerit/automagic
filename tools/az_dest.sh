for rg in $(az group list --query "[].name" --output tsv); do
  echo "Deleting resource group: $rg"
  az group delete --name "$rg" --yes --no-wait
done
