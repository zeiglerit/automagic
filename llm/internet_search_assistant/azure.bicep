// usage: az deployment group create \
//   --resource-group rag-rg \
//  --template-file main.bicep

// export AZURE_SEARCH_ENDPOINT="https://<your-search>.search.windows.net"
// export AZURE_SEARCH_KEY="<your-key>"

targetScope = 'resourceGroup'

param location string = 'eastus'
param rgName string = 'rag-rg'
param searchName string = 'rag-search'
param storageName string = 'ragstorage'
param containerEnvName string = 'rag-env'

resource search 'Microsoft.Search/searchServices@2023-11-01' = {
  name: searchName
  location: location
  sku: {
    name: 'basic'
  }
  properties: {
    hostingMode: 'default'
    partitionCount: 1
    replicaCount: 1
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource containerEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: containerEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
    }
  }
}

output searchEndpoint string = search.properties.hostName
output storageEndpoint string = storage.properties.primaryEndpoints.blob
