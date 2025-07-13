# Event Hubs Namespace
resource "azurerm_eventhub_namespace" "ehns" {
  name                = "ehns-${var.project_name}-realtime"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
}

# Event Hub for real-time vehicle updates
resource "azurerm_eventhub" "realtime" {
  name                = "evh-vehicle-updates"
  namespace_name      = azurerm_eventhub_namespace.ehns.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 1
}