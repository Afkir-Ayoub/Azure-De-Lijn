# Log Analytics Workspace that Application Insights will use for logs
resource "azurerm_log_analytics_workspace" "la" {
  name                = "log-${var.project_name}-ingest"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Storage account for Function app state.
resource "azurerm_storage_account" "func_storage" {
  name                     = "st${var.project_name}func01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Application Insights for logging and monitoring our functions.
resource "azurerm_application_insights" "app_insights" {
  name                = "appi-${var.project_name}-ingest"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.la.id
}

# Service Plan for Function App
resource "azurerm_service_plan" "plan" {
  name                = "plan-${var.project_name}-ingest"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

# The Function App
resource "azurerm_linux_function_app" "func_app" {
  name                = "func-${var.project_name}-ingest"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.func_storage.name
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      python_version = "3.12"
    }
  }

  # ENV vars for Python
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "AzureWebJobsStorage": azurerm_storage_account.func_storage.primary_connection_string, 
    "APPLICATIONINSIGHTS_CONNECTION_STRING": azurerm_application_insights.app_insights.connection_string,
    "ADLS_CONNECTION_STRING": azurerm_storage_account.adls.primary_connection_string,
    "EVENT_HUB_CONNECTION_STRING": azurerm_eventhub_namespace.ehns.default_primary_connection_string,
    "DE_LIJN_API_KEY_REALTIME": var.DE_LIJN_API_KEY_REALTIME,
    "DE_LIJN_API_KEY_STATIC":   var.DE_LIJN_API_KEY_STATIC
  }
}