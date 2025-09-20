provider "aws" {
  region = var.aws_region
}

# Create VPCs
resource "aws_vpc" "vpc" {
  for_each   = var.vpcs
  cidr_block = each.value.cidr_block
}

# Create Subnets
resource "aws_subnet" "subnet" {
  for_each = var.subnets
  vpc_id   = aws_vpc.vpc[each.value.vpc_key].id
  cidr_block = each.value.cidr_block
}

# Create Internet Gateways
resource "aws_internet_gateway" "igw" {
  for_each = var.igws
  vpc_id   = aws_vpc.vpc[each.value.vpc_key].id
}

# Create Route Tables
resource "aws_route_table" "rt" {
  for_each = var.rts
  vpc_id   = aws_vpc.vpc[each.value.vpc_key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[each.value.gateway_key].id
  }
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "rta" {
  for_each = var.subnets
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.rt["rts${substr(each.key, 6, 1)}"].id
}