terraform {
  backend "azurerm" {
    resource_group_name  = "tf-state-rg"
    storage_account_name = "tfstate<uniqueid>"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Example resource to test
resource "azurerm_resource_group" "myLabResourceGroup" {
  name     = "myLabResourceGroup"
  location = "East US"
}
