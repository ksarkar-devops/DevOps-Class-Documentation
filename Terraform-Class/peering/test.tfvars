aws_region = "us-east-1"

vpcs = {
  vpc1 = { cidr_block = "10.0.0.0/16" }
  vpc2 = { cidr_block = "10.1.0.0/16" }
}

subnets = {
  subnet1 = { cidr_block = "10.0.1.0/24", vpc_key = "vpc1", route_table_key = "rts1" }
  subnet2 = { cidr_block = "10.1.1.0/24", vpc_key = "vpc2", route_table_key = "rts2" }
}

internet_gateways = {
  igw1 = { vpc_key = "vpc1" }
  igw2 = { vpc_key = "vpc2" }
}

route_tables = {
  rts1 = { vpc_key = "vpc1", gateway_key = "igw1" }
  rts2 = { vpc_key = "vpc2", gateway_key = "igw2" }
}

peering_connections = {
  pcx1 = { requester_vpc_key = "vpc1", accepter_vpc_key = "vpc2", auto_accept = true }
}