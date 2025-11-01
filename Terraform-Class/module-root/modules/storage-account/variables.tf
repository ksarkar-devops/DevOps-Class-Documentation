variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  validation {
    condition = can(regex("^[a-z0-9]{3,24}$",
    var.storage_account_name))
    error_message = "Storage account name must be between 3 and 24 characters and contain only lowercase letters and numbers."
  }
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "East US"
}
variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either Standard or Premium."
  }
}
variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
  validation {
    condition = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS",
    "RAGZRS"], var.account_replication_type)
    error_message = "Invalid replication type."
  }
}
variable "account_kind" {
  description = "Storage account kind"
  type        = string
  default     = "StorageV2"
}
variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}
variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default     = {}
}
variable "containers" {
  description = "Map of storage containers to create"
  type = map(object({
    access_type = string
  }))
  default = {}
}