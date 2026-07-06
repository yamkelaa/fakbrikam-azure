// =========================================================
// main.bicep
// Deploys: 1 App Service Plan (Basic tier) + 1 Web App
// Target resource group: rg-fab-day01
// =========================================================

// ---- PARAMETERS ----
// Parameters let you reuse this template with different values
// without editing the file itself (e.g. via pipeline variables).

@description('Name of the App Service Plan')
param appServicePlanName string = 'asp-fab-day01'

@description('Name of the Web App (must be globally unique across all of Azure)')
// uniqueString() generates a short hash from the resource group ID,
// so the name stays unique even if you deploy this template more than once.
param webAppName string = 'app-fab-day01-${uniqueString(resourceGroup().id)}'

@description('Location for all resources')
// resourceGroup().location means: "whatever region the resource group is in"
// so you don't have to hardcode a region like 'eastus'.
param location string = resourceGroup().location

@description('SKU for the App Service Plan')
// B1 = Basic tier, smallest/cheapest Basic size. This controls pricing + capabilities.
param skuName string = 'B1'

// ---- RESOURCE 1: APP SERVICE PLAN ----
// Think of this as the "server" (compute + memory) that your app will run on.
// The Web App below doesn't run anything on its own — it needs this plan attached.
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName // e.g. 'B1' — the specific size/price point
    tier: 'Basic' // e.g. 'Basic' — the pricing tier/category
  }
  properties: {
    // reserved: true means "Linux-based plan". 
    // Set to false (or remove this line) if you want a Windows-based plan instead.
    reserved: true
  }
}

// ---- RESOURCE 2: WEB APP ----
// This is the actual app/website. It attaches to the App Service Plan above
// via serverFarmId — that's what links "the app" to "the server it runs on".
resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id // links this Web App to the plan created above
    siteConfig: {
      // Tells Azure which runtime/language stack to use to run your code.
      // PHP|8.2 means PHP version 8.2 on a Linux runtime.
      linuxFxVersion: 'PHP|8.2'
    }
  }
}

// ---- OUTPUTS ----
// Outputs print values after deployment finishes — useful for confirming
// what was created without having to go look it up manually in the portal.
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output webAppName string = webApp.name
