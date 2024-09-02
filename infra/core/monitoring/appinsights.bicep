@description('Name of the Application Insights resource')
param appInsightsName string

@description('Location for the Application Insights resource')
param location string

@description('Type of application monitored by Application Insights')
param applicationType string = 'web'

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: applicationType
  properties: {
    Application_Type: applicationType
  }
}

output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsResourceId string = appInsights.id
