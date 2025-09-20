provider "aws" {
  region = var.aws_region
}

# Create VPCs
resource "aws_vpc" "vpc" {
  for_each   = var.vpcs
  cidr_block = each.value.cidr_block

  tags = {
    Name = each.key
  }
}

# Create Subnets
resource "aws_subnet" "subnet" {
  for_each   = var.subnets
  vpc_id     = aws_vpc.vpc[each.value.vpc_key].id
  cidr_block = each.value.cidr_block

  tags = {
    Name = each.key
  }
}

# Create Internet Gateways
resource "aws_internet_gateway" "igw" {
  for_each = var.igws
  vpc_id   = aws_vpc.vpc[each.value.vpc_key].id

  tags = {
    Name = each.key
  }
}

# Create Route Tables
resource "aws_route_table" "rt" {
  for_each = var.rts
  vpc_id   = aws_vpc.vpc[each.value.vpc_key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[each.value.gateway_key].id
  }

  tags = {
    Name = each.key
  }
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "rta" {
  for_each = var.subnets
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.rt[each.value.route_table_key].id
}

# Create VPC Peering Connections
resource "aws_vpc_peering_connection" "pcx" {
  for_each = var.peering_connections

  vpc_id      = aws_vpc.vpc[each.value.requester_vpc_key].id
  peer_vpc_id = aws_vpc.vpc[each.value.accepter_vpc_key].id
  auto_accept = each.value.auto_accept

  tags = {
    Name = each.key
  }
}