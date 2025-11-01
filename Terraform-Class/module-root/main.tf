terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}
provider "azurerm" {
  features {}
}
locals {
  project_name = "terraformlab"
  environment  = "dev"
  location     = "East US"
  common_tags = {
    Environment = local.environment
    Project     = "Terraform Modules Lab"
    CreatedBy   = "Terraform"
  }
}
# Resource Group Module
module "resource_group" {
  source              = "./modules/resource-group"
  resource_group_name = "${local.project_name}-${local.environment}-rg"
  location            = local.location
  tags                = local.common_tags
}
module "storage_account" {
  source                   = "./modules/storage-account"
  resource_group_name      = module.resource_group.resource_group_name
  location                 = module.resource_group.resource_group_location
  storage_account_name     = "${local.project_name}${local.environment}sa001"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  environment              = local.environment
  tags                     = local.common_tags
  containers = {
    "uploads" = {
      access_type = "private"
    }
    "data" = {
      access_type = "private"
    }
  }
}