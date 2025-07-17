resource "azurerm_databricks_workspace" "dbw" {
  name                = "dbw-${var.project_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "standard"

  custom_parameters {
    no_public_ip = true # no premium tier, so we use no_public_ip to simplify config
  }
}