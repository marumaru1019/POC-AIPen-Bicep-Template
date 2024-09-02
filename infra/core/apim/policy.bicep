param serviceName string
param apiPath string

// ポリシーテンプレートの読み込み
var policy_template = loadTextContent('./apim-api-policy.xml')

resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-09-01-preview' = {
  name: '${serviceName}/${apiPath}/policy'
  properties: {
    value: policy_template
    format: 'rawxml'
  }
}

output policyId string = apiPolicy.id
