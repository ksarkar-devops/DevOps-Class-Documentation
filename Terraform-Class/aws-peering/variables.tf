variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "vpcs" {
  type = map(object({
    cidr_block = string
  }))
}

variable "subnets" {
  type = map(object({
    cidr_block      = string
    vpc_key         = string  # reference VPC by key
    route_table_key = string  # reference Route Table by key
  }))
}

variable "internet_gateways" {
  type = map(object({
    vpc_key = string
  }))
}

variable "route_tables" {
  type = map(object({
    vpc_key     = string
    gateway_key = string
  }))
}

variable "peering_connections" {
  type = map(object({
    requester_vpc_key = string
    accepter_vpc_key  = string
    auto_accept       = bool
  }))
}