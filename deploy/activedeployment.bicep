param app string

resource the_app 'Microsoft.AppPlatform/Spring/apps@2020-07-01' = {
  name: app
  properties: {
    public: true
    activeDeploymentName: 'default'
  }
}
