output "resource_group_info" {
  description = "Resource group information"
  value = {
    name     = module.resource_group.resource_group_name
    location = module.resource_group.resource_group_location
    id       = module.resource_group.resource_group_id
  }
}
output "storage_account_info" {
  description = "Storage account information"
  value = {
    name             = module.storage_account.storage_account_name
    id               = module.storage_account.storage_account_id
    primary_location = module.resource_group.resource_group_location
  }
  sensitive = true
}
output "storage_containers" {
  description = "Created storage containers"
  value       = module.storage_account.containers
}