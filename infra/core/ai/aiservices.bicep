@description('Name of the Azure OpenAI resource')
param openAiServiceName string

@description('Location of the Azure OpenAI resource')
param location string

@description('SKU for the Azure OpenAI service')
param openAiSkuName string = 'S0'

@description('Name of the first DALL·E model')
param modelName string

@description('Name of the second DALL·E model')
param dalleModelName1 string

@description('Name of the second DALL·E model')
param dalleModelName2 string

// @description('Name of the second DALL·E model')
// param dalleModel2Name string = 'dalle-model-2'

// Azure OpenAI リソースの作成
resource openAI 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
  name: openAiServiceName
  location: location
  kind: 'OpenAI'
  sku: {
    name: openAiSkuName
  }
  properties: {
    apiProperties: {
      enableOpenAIGen: true
    }
  }
}

// DALL·E 3 モデル1のデプロイメント
resource gptDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: modelName
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-05-13'
    }
  }
  dependsOn: [openAI]
  sku: {
      name: 'Standard'  // SKUの指定
      capacity: 10
  }
  parent: openAI
}

// // DALL·E 3 モデル2のデプロイメント
resource dalleDeployment1 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: dalleModelName1
  location: location
  dependsOn: [gptDeployment]
  properties: {
    model: {
      format: 'OpenAI'
      name: 'dall-e-3'
      version: '3.0'
    }
  }
  sku: {
      name: 'Standard'  // SKUの指定
      capacity: 1
  }
  parent: openAI
}

resource dalleDeployment2 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: dalleModelName2
  location: location
  dependsOn: [dalleDeployment1]
  properties: {
    model: {
      format: 'OpenAI'
      name: 'dall-e-3'
      version: '3.0'
    }
  }
  sku: {
      name: 'Standard'  // SKUの指定
      capacity: 1
  }
  parent: openAI
}

// リソース名の出力
output openAiResourceName string = openAI.name

// エンドポイントの出力
output openAiEndpoint string = 'https://${openAI.name}.cognitiveservices.azure.com/'
