# AI Pen Bicep テンプレート
## 概要
AI Penは、声で漫画や絵を生成できるアプリケーションを構築するためのBicepテンプレートです。このテンプレートを使用して、Azure上に必要なリソースを自動的にデプロイし、アプリケーションを迅速に構築することができます。

## 前提条件
このテンプレートを使用するためには、以下の環境が必要です。
- Azureサブスクリプション
- Azure CLI
- Azure Developer CLI
- Git

### Azure Developer CLIのインストール
Azure Developer CLIは、Azureのリソースを管理するためのコマンドラインツールです。[ドキュメント](https://learn.microsoft.com/ja-jp/azure/developer/azure-developer-cli/get-started?tabs=localinstall&pivots=programming-language-nodejs)に従ってインストールしてください。

## 構築手順
### 1. リポジトリのクローン
このリポジトリをクローンしてください。
```bash
git clone https://github.com/marumaru1019/POC-AIPen-Bicep-Template.git
```

### 2. main.parameters.jsonの編集
`main.parameters.json`を編集して、デプロイするリソースの設定を行ってください。
例で値が設定されていますが、説明に従って値を変更してください。

```:main.parameters.json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environmentName": {
      "value": "prod" 
      // 環境の名前（例: dev, staging, prod）を指定します。デプロイメントの区別に使用されます。
    },
    "location": {
      "value": "eastus" 
      // リソースを展開するリージョン (例: eastus, japaneast) を指定します。選択するリージョンにより、レイテンシーやサービス可用性が異なります。
    },
    "resourceGroupName": {
      "value": "rg-aipen" 
      // リソースグループの名前を指定します。すべてのAzureリソースは、リソースグループに属します。
    },
    "openAiServiceName1": {
      "value": "openai-aipen-1" 
      // 1つ目のAzure OpenAIサービスの名前を指定します。デプロイされるOpenAIサービスを区別するために使用します。
    },
    "openAiServiceName2": {
      "value": "openai-aipen-2" 
      // 2つ目のAzure OpenAIサービスの名前を指定します。複数のサービスをデプロイする場合に使用します。
    },
    "gptDeploymentCapacity": {
      "value": 10 
      // GPTモデルデプロイメントの容量を指定します。これは必要なスケールや性能に応じて調整します。
    },
    "dalleDeploymentCapacity": {
      "value": 1 
      // DALL·Eモデルデプロイメントの容量を指定します。GPTと同様に、スケールや性能に応じて調整します。
    },
    "appInsightsName": {
      "value": "app-insights-aipen" 
      // Application Insightsのリソース名を指定します。アプリケーションのパフォーマンスと診断情報を監視するために使用します。
    },
    "appServiceName": {
      "value": "appservice-aipen" 
      // App Serviceの名前を指定します。ウェブアプリケーションのホスティングに使用されるAzureサービスです。
    },
    "appServicePlanName": {
      "value": "appserviceplan-aipen" 
      // App Service Planの名前を指定します。App Serviceが使用するスケーリングと料金オプションを管理します。
    },
    "skuName": {
      "value": "P1v2" 
      // App Service PlanのSKUを指定します。料金や性能レベルを決定します（例: F1, B1, P1v2など）。
    },
    "apiPath": {
      "value": "create-image" 
      // APIのエンドポイントパスを指定します。この例では、画像生成APIのパスとして使用されます。
    },
    "publisherEmail": {
      "value": "contoso@microsoft.com" 
      // API Managementサービスのパブリッシャーのメールアドレスを指定します。エンドユーザーへの連絡先情報として使用されます。
    },
    "publisherName": {
      "value": "Contoso" 
      // API Managementサービスのパブリッシャー名を指定します。公開されるAPIに関連付けられる名前です。
    },
    "serviceName": {
      "value": "poc-apim-samplesample23" 
      // API Managementサービスの名前を指定します。デプロイされるAPI Managementインスタンスの識別子として使用します。名前は一意である必要があります。
    }
  }
}
``` 

### 3. デプロイ
#### Azureにログイン
`azd auth login`コマンドを使用してAzureにログインします。
```bash
cd POC-AIPen-Bicep-Template
azd auth login
```

#### デプロイ
`azd up`コマンドを使用して、Bicepテンプレートをデプロイします。
```bash
azd up
```

デプロイが完了すると以下のようなメッセージが表示されます。
```
Deployment has completed successfully.
```

Azure Portalを開いて、作成したリソースグループを確認して下記のリソースがデプロイされていることを確認してください。

- Azure OpenAIサービス × 2
- App Service
- App Service Plan
- Application Insights
- API Management

### 4. API Management の Policy の設定
API Management の Policy に以下の設定を追加します。

#### OpenAI API Key の確認
az cli で下記のコマンドを実行して、作成した 2 つの OpenAI サービスのキーを確認してください。
```bash
az cognitiveservices account keys list --resource-group <resource-group-name> --name <openai-service-name>
```

下記のような結果が表示されますので、`key1` または `key2` の値をコピーしてください。
```json
{
  "key1": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "key2": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
```

#### API Management の Policy の設定
API Management の Policy に OpenAI API のキーを設定します。
`19行目と51行目`に1つめのOpenAIサービスのキーを、`25行目と57行目`に2つめのOpenAIサービスのキーを設定してください。

```xml:apim-api-policy.xml
・・・
<choose>
    <when condition="@(context.Variables.GetValueOrDefault<int>("randomNumber", 0) == 1)">
        <set-backend-service base-url="https://eastus.api.cognitive.microsoft.com/openai" />
        <set-header name="api-key" exists-action="override">
            <value>your_api_key1</value> <!-- ここに1つめのOpenAIサービスのキーを設定 -->
        </set-header>
    </when>
    <when condition="@(context.Variables.GetValueOrDefault<int>("randomNumber", 0) == 2)">
        <set-backend-service base-url="https://eastus.api.cognitive.microsoft.com/openai" />
        <set-header name="api-key" exists-action="override">
            <value>your_api_key2</value> <!-- ここに2つめのOpenAIサービスのキーを設定 -->
        </set-header>
    </when>
</choose>

・・・

<on-error>
    <base />
    <retry condition="@(context.Response.StatusCode != 200)" count="1" interval="0">
        <set-variable name="fallbackRandomNumber" value="@(new Random().Next(1, 3))" />
        <choose>
            <when condition="@(context.Variables.GetValueOrDefault<int>("fallbackRandomNumber", 0) == 1)">
                <set-backend-service base-url="https://eastus.api.cognitive.microsoft.com/openai" />
                <set-header name="api-key" exists-action="override">
                    <value>your_api_key1</value> <!-- ここに1つめのOpenAIサービスのキーを設定 -->
                </set-header>
            </when>
            <when condition="@(context.Variables.GetValueOrDefault<int>("fallbackRandomNumber", 0) == 2)">
                <set-backend-service base-url="https://eastus.api.cognitive.microsoft.com/openai" />
                <set-header name="api-key" exists-action="override">
                    <value>your_api_key2</value> <!-- ここに2つめのOpenAIサービスのキーを設定 -->
                </set-header>
            </when>
        </choose>
    </retry>
</on-error>
```

Azure PortalにてPolicyを編集するか、再度`azd up`コマンドを実行してデプロイしてください。

```bash
azd up
```