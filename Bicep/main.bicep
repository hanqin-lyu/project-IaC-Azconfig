param location string = resourceGroup().location

resource nsg 'Microsoft.Network/networkSecurityGroups@2025-07-01' = {
  name: 'myNSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: 'myVNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'mySubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
          {
            service: 'Microsoft.Sql'
          }
          {
            service: 'Microsoft.KeyVault'
          }
          {
            service: 'Microsoft.CognitiveServices'
          }
        ]
      }
      }
    ]  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: 'st${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: '${vnet.id}/subnets/mySubnet'
        }
      ]
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2025-01-01' = {
  name: 'sqlserver${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: 'P@ssw0rd1234!'
    version: '12.0'
  }
}

resource sqlvirtualNetworkRule 'Microsoft.Sql/servers/virtualNetworkRules@2025-01-01' = {
  name: '${sqlServer.name}-${uniqueString(resourceGroup().id)}'
  parent: sqlServer
  properties: {
    virtualNetworkSubnetId: '${vnet.id}/subnets/mySubnet'
    ignoreMissingVnetServiceEndpoint: false
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2025-01-01' = {
  name: '${sqlServer.name}-${uniqueString(resourceGroup().id)}'
  parent: sqlServer
  location: location
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
  }
}


resource keyVault 'Microsoft.KeyVault/vaults@2026-02-01' = {
  name: 'kv${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: '${vnet.id}/subnets/mySubnet'
        }
      ]
    }
  }
}

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2026-03-01' = {
  name: 'cogsvc${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'S1'
  }
  kind: 'CognitiveServices'
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: '${vnet.id}/subnets/mySubnet'
        }
      ]
    }
  }
}
