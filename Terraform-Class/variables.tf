variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "HOVnet"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["172.21.0.0/16"]
}

variable "subnets" {
  description = "List of subnets to create with their address prefixes"
  type = list(object({
    name           = string
    address_prefix = string
  }))
  default = [
    {
      name           = "AppSn"
      address_prefix = "172.21.10.0/24"
    },
    {
      name           = "DataSn"
      address_prefix = "172.21.20.0/24"
    },
    {
      name           = "WebSn"
      address_prefix = "172.21.30.0/24"
    }
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "HOVnet"
    CreatedBy   = "Terraform"
  }
}
