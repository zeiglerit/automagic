@description('Name of the resource group')
param resourceGroupName string

@description('Location for deployment')
param location string = 'eastus'

@description('Name of the Azure ML workspace')
param amlWorkspaceName string = 'osint-llm-workspace'

@description('Name of the compute cluster')
param computeName string = 'osint-llm-cluster'

@description('VM size for LLM compute')
param vmSize string = 'Standard_NC6'

@description('Min nodes in cluster')
param minNodes int = 0

@description('Max nodes in cluster')
param maxNodes int = 1

resource aml 'Microsoft.MachineLearningServices/workspaces@2023-04-01' = {
  name: amlWorkspaceName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: amlWorkspaceName
    description: 'LLM workspace for OSINT and dark web SME'
  }
}

resource compute 'Microsoft.MachineLearningServices/workspaces/computes@2023-04-01' = {
  parent: aml
  name: computeName
  location: location
  properties: {
    computeType: 'AmlCompute'
    properties: {
      vmSize: vmSize
      scaleSettings: {
        minNodeCount: minNodes
        maxNodeCount: maxNodes
        nodeIdleTimeBeforeScaleDown: 'PT30M'
      }
    }
  }
}

output workspaceId string = aml.id
output computeId string = compute.id
