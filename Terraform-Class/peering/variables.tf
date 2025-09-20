variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "vpc1" {
  type        = object({
    name           = string
    cidr_block     = string
  })
  default = {
      name           = "AppSn"
      cidr_block     = "172.21.10.0/24"
    }
}

variable "app_subnet_cidr" {
  description = "CIDR block for the App subnet"
  type        = string
  default     = "172.20.10.0/24"
}
