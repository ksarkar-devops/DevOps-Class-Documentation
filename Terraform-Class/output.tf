# Resource Group Outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Virtual Network Outputs
output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "virtual_network_address_space" {
  description = "The address space of the virtual network"
  value       = azurerm_virtual_network.main.address_space
}

# Subnet Outputs
output "subnet_ids" {
  description = "The IDs of all created subnets"
  value       = { for k, v in azurerm_subnet.main : k => v.id }
}

output "subnet_address_prefixes" {
  description = "The address prefixes of all created subnets"
  value       = { for k, v in azurerm_subnet.main : k => v.address_prefixes }
}

output "subnet_details" {
  description = "Detailed information about all subnets"
  value = { for k, v in azurerm_subnet.main : k => {
    id              = v.id
    name            = v.name
    address_prefixes  = v.address_prefixes
  }}
}

# Complete deployment summary
output "deployment_summary" {
  description = "Summary of all created resources"
  value = {
    resource_group = {
      name     = azurerm_resource_group.main.name
      id       = azurerm_resource_group.main.id
      location = azurerm_resource_group.main.location
    }
    virtual_network = {
      name          = azurerm_virtual_network.main.name
      id            = azurerm_virtual_network.main.id
      address_space = azurerm_virtual_network.main.address_space
    }
    subnets = { for k, v in azurerm_subnet.main : k => {
      name           = v.name
      id             = v.id
      address_prefixes = v.address_prefixes
    }}
  }
}
