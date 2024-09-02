@description('Name of the API Management service')
param serviceName string

@description('Location for the API Management service')
param location string = 'Japan East'

@description('The SKU of the API Management service')
param skuName string = 'StandardV2'

@description('Publisher Email for the API Management service')
param publisherEmail string

@description('Publisher Name for the API Management service')
param publisherName string

@description('Host Name for the API Management service')
param hostname string = '${serviceName}.azure-api.net'

// API Management Service
resource apiManagementService 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: serviceName
  location: location
  sku: {
    name: skuName
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: hostname
        negotiateClientCertificate: false
        defaultSslBinding: true
        certificateSource: 'BuiltIn'
      }
    ]
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'False'
    }
    virtualNetworkType: 'None'
    enableClientCertificate: false
    natGatewayState: 'Enabled'
    apiVersionConstraint: {}
    publicNetworkAccess: 'Enabled'
    legacyPortalStatus: 'Disabled'
    developerPortalStatus: 'Disabled'
  }
}

output apiManagementServiceId string = apiManagementService.id
