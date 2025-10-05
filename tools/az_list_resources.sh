#!/bin/bash

QUERY_ALL_SUBSCRIPTIONS=false
OUTPUT_FORMAT="table"

az resource list --output table

list_resources() {
    local subscription="$1"
    echo -e "\n🔹 Subscription: $subscription"
    az account set --subscription "$subscription"

    rg_list=$(az group list --query "[].name" -o tsv)
    if [[ -z "$rg_list" ]]; then
        echo "  ..NADA (no resource groups)"
        return
    fi

    for rg in $rg_list; do
        echo -e "\n  ▪ Resource Group: $rg"
        resources=$(az resource list --resource-group "$rg" --query "[].name" -o tsv)
        if [[ -z "$resources" ]]; then
            echo "    ..NADA"
        else
            az resource list --resource-group "$rg" --output "$OUTPUT_FORMAT"
        fi
    done
}

if $QUERY_ALL_SUBSCRIPTIONS; then
    subs=$(az account list --query "[].id" -o tsv)
    for sub in $subs; do
        list_resources "$sub"
    done
else
    current_sub=$(az account show --query "id" -o tsv)
    list_resources "$current_sub"
fi