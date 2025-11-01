variable "environment" {
description = "The deployment environment"
type = string
default = "dev"
}
variable "location" {
description = "The Azure region to deploy resources"
type = string
default = "East US"
}
variable "project_name" {
description = "Name of the project"
type = string
default = "terraformlab"
}
