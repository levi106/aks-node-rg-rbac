targetScope = 'subscription'

param aksResourceGroup string = 'rbac-test-rg'
param location string = 'eastus'
param nodeResourceGroup string = 'node-rbac-test-rg'
@description('principalId of the user that will be given contributor access to the resourceGroup')
param principalId string

@description('roleDefinition to apply to the resourceGroup - default is reader')
param roleDefinitionId string = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

var roleID = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleDefinitionId}'

resource aksRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: aksResourceGroup
  location: location
}

module aks 'aks.bicep' = {
  name: 'aks'
  scope: resourceGroup(aksRg.name)
  params: {
    nodeResourceGroup: nodeResourceGroup
  }
}

module role 'role.bicep' = {
  name: 'role'
  dependsOn: [aks]
  scope: resourceGroup(nodeResourceGroup)
  params: {
    principalId: principalId
    roleNameGuid: guid(principalId, roleDefinitionId, nodeResourceGroup)
    roleDefinitionId: roleID
  }
}
