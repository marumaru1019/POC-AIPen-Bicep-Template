targetScope = 'subscription'

@description('Name of the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@description('Primary location for all resources')
param location string

@description('Name of the resource group to create or use')
param resourceGroupName string

@description('Name of the Azure OpenAI service 1')
param openAiServiceName1 string

@description('Name of the Azure OpenAI service 2')
param openAiServiceName2 string

@description('Capacity for the GPT deployment')
param gptDeploymentCapacity int = 10

@description('Name of the first DALL·E model')
param dalleModelName string = 'dall-e-3'

@description('Capacity for the DALL·E deployment')
param dalleDeploymentCapacity int = 1

@description('Name of the App Service')
param appServiceName string

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Name of the Application Insights resource')
param appInsightsName string

@description('SKU for the App Service Plan')
param skuName string = 'P1v2'

@description('API Path for Image Creation')
param apiPath string = 'create-image'

@description('Publisher email for API Management service')
param publisherEmail string

@description('Publisher name for API Management service')
param publisherName string

@description('Name of the API Management service')
param apiServiceName string

// abbreviation.json の読み込み
var abbrs = loadJsonContent('abbreviations.json')

// 一意のリソース名を生成するためのトークン
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))


// リソースグループの作成
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
}

// OpenAI Resource のデプロイ
module openAiResource1 './core/ai/openaiResource.bicep' = {
  name: 'deployOpenAiResource1'
  scope: resourceGroup
  params: {
    openAiServiceName: openAiServiceName1
    openAiSkuName: 'S0'
  }
}

module openAiResource2 './core/ai/openaiResource.bicep' = {
  name: 'deployOpenAiResource2'
  scope: resourceGroup
  params: {
    openAiServiceName: openAiServiceName2
    openAiSkuName: 'S0'
  }
}

// GPT Deployment のデプロイ
module gptDeployment './core/ai/gptDeployment.bicep' = {
  name: 'deployGptDeployment'
  scope: resourceGroup
  params: {
    openAiServiceName: openAiServiceName1
    gptDeploymentName: 'gpt-4o'
    gptDeploymentCapacity: gptDeploymentCapacity
  }
  dependsOn: [
    openAiResource1
  ]
}

// DALL·E Deployments のデプロイ
module dalleDeployment1 './core/ai/dalleDeployment.bicep' = {
  name: 'deployDalleDeployment1'
  scope: resourceGroup
  params: {
    openAiServiceName: openAiServiceName1
    dalleModelName: dalleModelName
    dalleDeploymentCapacity: dalleDeploymentCapacity
  }
  dependsOn: [
    openAiResource1
  ]
}

module dalleDeployment2 './core/ai/dalleDeployment.bicep' = {
  name: 'deployDalleDeployment2'
  scope: resourceGroup
  params: {
    openAiServiceName: openAiServiceName2
    dalleModelName: dalleModelName
    dalleDeploymentCapacity: dalleDeploymentCapacity
  }
  dependsOn: [
    openAiResource2
  ]
}

// Call the Application Insights module
module appInsights './core/monitoring/appinsights.bicep' = {
  name: 'deployAppInsights'
  scope: resourceGroup
  params: {
    appInsightsName: appInsightsName
    location: location
  }
}

// App Service のデプロイ
module appService './core/host/appservice.bicep' = {
  name: 'deployAppService'
  scope: resourceGroup
  params: {
    appServiceName: appServiceName
    appServicePlanName: appServicePlanName
    location: location
    skuName: skuName
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    appInsightsConnString: appInsights.outputs.appInsightsConnectionString
    appInsightsResourceId: appInsights.outputs.appInsightsResourceId
  }
  dependsOn: [
    appInsights
  ]
}

// API Management Service のデプロイ
module apim './core/apim/apim.bicep' = {
  name: 'deployApiManagementService'
  scope: resourceGroup
  params: {
    serviceName: apiServiceName
    location: location
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

// API のデプロイ
module api './core/apim/api.bicep' = {
  name: 'deployApi'
  scope: resourceGroup
  params: {
    serviceName: apiServiceName
    apiPath: apiPath
    dalleModelName: dalleModelName
  }
  dependsOn: [
    dalleDeployment1
    dalleDeployment2
    apim
  ]
}

// API Policy のデプロイ
module policy './core/apim/policy.bicep' = {
  name: 'deployApiPolicy'
  scope: resourceGroup
  params: {
    serviceName: apiServiceName
    apiPath: apiPath
  }
  dependsOn: [
    api
  ]
}

// 出力として OpenAI サービス名、エンドポイント、および App Service の URL を返す
output openAiResourceName1 string = openAiResource1.outputs.openAiResourceName
output openAiEndpoint1 string = openAiResource1.outputs.openAiEndpoint
output openAiResourceName2 string = openAiResource2.outputs.openAiResourceName
output openAiEndpoint2 string = openAiResource2.outputs.openAiEndpoint
output appServiceUrl string = appService.outputs.appServiceUrl
output apimServiceId string = apim.outputs.apiManagementServiceId
output apiId string = api.outputs.apiId
output policyId string = policy.outputs.policyId
