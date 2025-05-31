# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "RG11"
  location = "eastus2"
  
  tags = {
    Environment = "Terraform Getting Started"
    Team = "DevOps"
  }
}
# Create a HO virtual network
resource "azurerm_virtual_network" "HO" {
  name                = "HO"
  address_space       = ["172.16.0.0/16"]
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.rg.name

}
# Create subnet for HO_subnet
resource "azurerm_subnet" "HO_subnet" {
  name                 = "HO_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.HO.name
  address_prefixes     = ["172.16.10.0/24"]
}


# Create a Branch virtual network
resource "azurerm_virtual_network" "Branch" {
  name                = "Branch"
  address_space       = ["172.20.0.0/16"]
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.rg.name

}
# Create subnet for Branch_subnet
resource "azurerm_subnet" "Branch_subnet" {
  name                 = "Branch_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.Branch.name
  address_prefixes     = ["172.20.10.0/24"]
}


# Create Peering between HOvnet and Branchvnet
resource "azurerm_virtual_network_peering" "peering_hovnet_to_Branchvnet" {
  name                      = "HOvnet-to-Branchvnet"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.HO.name
  remote_virtual_network_id = azurerm_virtual_network.Branch.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "peering_Branchvnet_to_hovnet" {
  name                      = "Branchvnet-to-HOvnet"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.Branch.name
  remote_virtual_network_id = azurerm_virtual_network.HO.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}
