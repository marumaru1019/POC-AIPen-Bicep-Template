@description('Name of the App Service')
param appServiceName string

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Location for the App Service')
param location string = 'japaneast'

@description('SKU for the App Service Plan')
param skuName string = 'P1v2'

@description('Instrumentation key for Application Insights')
param appInsightsInstrumentationKey string

@description('Connection string for Application Insights')
param appInsightsConnString string

@description('Application Insights Resource ID')
param appInsightsResourceId string

// App Service Plan の作成
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: 'PremiumV2'
    size: 'P1v2'
    capacity: 1
  }
  properties: {
    reserved: true
    perSiteScaling: false
    maximumElasticWorkerCount: 1
  }
}

// App Service の作成
resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceName
  location: location
  tags: {
    'hidden-link: /app-insights-resource-id': appInsightsResourceId
    'hidden-link: /app-insights-instrumentation-key': appInsightsInstrumentationKey
    'hidden-link: /app-insights-conn-string': appInsightsConnString
    'azd-service-name': 'webApp'
  }
  kind: 'app,linux'
  properties: {
    enabled: true
    serverFarmId: appServicePlan.id
    reserved: true
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'PYTHON|3.9'
      alwaysOn: true
      appCommandLine: 'gunicorn --bind=0.0.0.0 --timeout 600 generate_html:app'
      appSettings: [
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
      ]
    }
    httpsOnly: true
  }
}

resource appServiceFtpPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  name: '${appServiceName}/ftp'
  location: location
  properties: {
    allow: false
  }
  dependsOn: [
    appService
  ]
}

resource appServiceScmPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  name: '${appServiceName}/scm'
  location: location
  properties: {
    allow: false
  }
  dependsOn: [
    appService
  ]
}

resource appServiceConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  name: '${appServiceName}/web'
  location: location
  properties: {
    linuxFxVersion: 'PYTHON|3.9'
    alwaysOn: true
    appCommandLine: 'gunicorn --bind=0.0.0.0 --timeout 600 generate_html:app'
    ftpsState: 'FtpsOnly'
    minTlsVersion: '1.2'
  }
  dependsOn: [
    appService
  ]
}

resource appServiceHostNameBinding 'Microsoft.Web/sites/hostNameBindings@2023-12-01' = {
  name: '${appServiceName}/${appServiceName}.azurewebsites.net'
  location: location
  properties: {
    siteName: appServiceName
    hostNameType: 'Verified'
  }
  dependsOn: [
    appService
  ]
}

output appServiceUrl string = 'https://${appServiceName}.azurewebsites.net'
