@description('Name of the Azure OpenAI resource')
param openAiServiceName string

@description('Name of the first DALL·E model deployment')
param dalleModelName string

@description('Capacity of the DALL·E deployment')
param dalleDeploymentCapacity int = 1

// Existing OpenAI resource reference
resource openAI 'Microsoft.CognitiveServices/accounts@2022-12-01' existing = {
  name: openAiServiceName
}

// DALL·E 3 モデル1のデプロイメント
resource dalleDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: dalleModelName
  properties: {
    model: {
      format: 'OpenAI'
      name: 'dall-e-3'
      version: '3.0'
    }
  }
  parent: openAI
  sku: {
    name: 'Standard'  
    capacity: dalleDeploymentCapacity
  }
}
