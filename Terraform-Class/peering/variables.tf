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
    vpc1 = {
      cidr_block = "10.0.0.0/16"
    }
    vpc2 = {
      cidr_block = "10.1.0.0/16"
    }
  }
}

variable "subnets" {
  type = map(object({
    cidr_block = string
    vpc_id     = string

  }))

  default = {
    subnet1 = {
      cidr_block = "10.0.1.0/24"
      vpc_id     = "vpc1"
    }
    subnet2 = {
      cidr_block = "10.1.1.0/24"
      vpc_id     = "vpc2"
    }
  }
}

variable "igws" {
  type = map(object({
    vpc_id = string
  }))

  default = {
    igw1 = {
      vpc_id     = "vpc1"
    }
    igw2 = {
      vpc_id     = "vpc2"
    }
  }
}

variable "rts" {
  type = map(object({
    vpc_id     = string
    cidr_block = string
    gateway_id = string
  }))

  default = {
    rts1 = {
      vpc_id     = "vpc1"
      gateway_id = "igw1"
    }
    rts2 = {
      vpc_id     = "vpc2"
      gateway_id = "igw2"
    }
  }
}
