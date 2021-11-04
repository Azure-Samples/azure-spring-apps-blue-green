param spring_cloud_name string = 'spring-cloud-service'
param appName string = 'gateway'
param location string = resourceGroup().location


resource springcloudservice 'Microsoft.AppPlatform/Spring@2021-06-01-preview' = {
  name: spring_cloud_name
  location: location
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
}

resource springcloudservice_config 'Microsoft.AppPlatform/Spring/configServers@2021-06-01-preview' = {
  name: '${springcloudservice.name}/default'
  properties: {
    configServer: {
      gitProperty: {
        uri: 'https://github.com/Azure-Samples/piggymetrics-config'
      }
    }
  }
}

resource the_app 'Microsoft.AppPlatform/Spring/apps@2021-06-01-preview' = {
  name: '${springcloudservice.name}/${appName}'
  location: location
  properties: {
    public: true
  }
}

resource app_deployment 'Microsoft.AppPlatform/Spring/apps/deployments@2021-06-01-preview' = {
  name: '${the_app.name}/default'
  properties: {
    source: {
      relativePath: '<default>'
      type: 'Jar'
    }
  }
}

module activeDeployment './activedeployment.bicep' = {
  name: 'setActiveDeployment'
  params: {
    app: the_app.name
  }
  dependsOn: [
    app_deployment
  ]
}
