@description('Name of the Azure OpenAI resource')
param openAiServiceName string

@description('Name of the GPT deployment')
param gptDeploymentName string

@description('Capacity of the GPT deployment')
param gptDeploymentCapacity int = 10

// Existing OpenAI resource reference
resource openAI 'Microsoft.CognitiveServices/accounts@2022-12-01' existing = {
  name: openAiServiceName
}

// GPTモデルのデプロイメント
resource gptDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: gptDeploymentName
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-05-13'
    }
  }
  parent: openAI
  sku: {
    name: 'Standard'  // SKUの指定
    capacity: gptDeploymentCapacity
  }
}
