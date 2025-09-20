# Create VPC
resource "aws_vpc" "main" {
    for_each = var.vpcs

    cidr_block           = each.cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = each.key
    }
}

# Create public subnet
resource "aws_subnet" "main" {
    for_each = var.subnets

    vpc_id                  = each.vpc_id
    cidr_block              = each.cidr_block
    availability_zone       = var.aws_region
    map_public_ip_on_launch = true # Automatically assign public IP to instances

    tags = {
        Name = each.key
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
    for_each = var.igws

    vpc_id = each.vpc_id

    tags = {
        Name = each.key
    }
}

# Create route table
resource "aws_route_table" "public" {
    for_each = var.rts

    vpc_id = each.vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = each.gateway_id
    }

    tags = {
        Name = each.key
    }
}