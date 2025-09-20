variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "vpcs" {
  type = map(object({
    cidr_block = string
  }))

  default = {
    vpc1 = { cidr_block = "10.0.0.0/16" }
    vpc2 = { cidr_block = "10.1.0.0/16" }
  }
}

variable "subnets" {
  type = map(object({
    cidr_block      = string
    vpc_key         = string  # reference VPC by key
    route_table_key = string  # reference Route Table by key
  }))

  default = {
    subnet1 = { cidr_block = "10.0.1.0/24", vpc_key = "vpc1", route_table_key = "rts1" }
    subnet2 = { cidr_block = "10.1.1.0/24", vpc_key = "vpc2", route_table_key = "rts2" }
  }
}

variable "igws" {
  type = map(object({
    vpc_key = string
  }))

  default = {
    igw1 = { vpc_key = "vpc1" }
    igw2 = { vpc_key = "vpc2" }
  }
}

variable "rts" {
  type = map(object({
    vpc_key     = string
    gateway_key = string
  }))

  default = {
    rts1 = { vpc_key = "vpc1", gateway_key = "igw1" }
    rts2 = { vpc_key = "vpc2", gateway_key = "igw2" }
  }
}