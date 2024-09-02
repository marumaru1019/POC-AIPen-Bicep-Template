@description('Name of the API Management service')
param serviceName string

@description('API Path for Image Creation')
param apiPath string = 'create-image'

@description('Backend Service URL for DALL-E 3 API')
param dalleBackendUrl string = 'https://eastus.api.cognitive.microsoft.com'

@description('API Name')
param apiName string = 'POC CREATE IMAGES'

@description('Name of Dalle Deployment')
param dalleModelName string

// API Definition
resource api 'Microsoft.ApiManagement/service/apis@2023-09-01-preview' = {
  name: '${serviceName}/${apiPath}'
  properties: {
    displayName: apiName
    apiRevision: '1'
    subscriptionRequired: true
    serviceUrl: dalleBackendUrl
    protocols: [
      'https'
    ]
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    isCurrent: true
    path: apiPath
  }
}

// API Operation
resource apiOperation 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' = {
  name: '${serviceName}/${apiPath}/post-generate-image'
  dependsOn: [
    api
  ]
  properties: {
    displayName: 'Generate image using DALL-E 3'
    method: 'POST'
    urlTemplate: '/deployments/${dalleModelName}/images/generations?api-version={api-version}'
    templateParameters: [
      {
        name: 'api-version'
        type: 'string'
        required: true
        values: []
      }
    ]
    description: 'Generate image using DALL-E 3'
    request: {
      representations: [
        {
          contentType: 'application/json'
          examples: {
            default: {
              value: {
                prompt: 'string'
                n: 0
                size: 'string'
              }
            }
          }
        }
      ]
    }
    responses: [
      {
        statusCode: 200
        description: 'Image generated'
        representations: [
          {
            contentType: 'application/json'
            examples: {
              default: {
                value: {
                  images: [
                    'string'
                  ]
                }
              }
            }
          }
        ]
      }
    ]
  }
}

output apiId string = api.id
