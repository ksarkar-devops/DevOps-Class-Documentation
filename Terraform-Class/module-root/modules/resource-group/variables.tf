variable "resource_group_name" {
description = "The name of the resource group"
type = string
validation {
condition = length(var.resource_group_name) >= 2 &&
length(var.resource_group_name) <= 90
error_message = "Resource group name must be between 2 and 90
characters long."
}
}
variable "location" {
description = "The Azure region where the resource group will be created"
type = string
default = "East US"
}
variable "tags" {
description = "A map of tags to apply to the resource group"
type = map(string)
default = {}
}
