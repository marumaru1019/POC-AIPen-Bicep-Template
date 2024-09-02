@description('Name of the Azure OpenAI resource')
param openAiServiceName string

@description('SKU for the Azure OpenAI service')
param openAiSkuName string = 'S0'

// Azure OpenAI リソースの作成
resource openAI 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
  name: openAiServiceName
  location: 'eastus'
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

// リソース名の出力
output openAiResourceName string = openAI.name

// エンドポイントの出力
output openAiEndpoint string = 'https://${openAI.name}.cognitiveservices.azure.com/'
