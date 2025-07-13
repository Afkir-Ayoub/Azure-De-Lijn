terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfdelijnstate"
    container_name       = "tfstate"
    key                  = "delijn.terraform.tfstate"
  }
}