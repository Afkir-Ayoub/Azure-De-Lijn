# Resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-data-platform"
  location = var.location
}

# ADLS Gen2 storage account
resource "azurerm_storage_account" "adls" {
  name                     = "st${var.project_name}datalake01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
}

# Medallion storage containers
resource "azurerm_storage_container" "bronze" {
  name                  = "bronze"
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold" {
  name                  = "gold"
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"
}