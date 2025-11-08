# Create VPCs
resource "aws_vpc" "main" {
  for_each   = var.vpcs
  cidr_block = each.value.cidr_block

  tags = {
    Name = each.key
  }
}

# Create Subnets
resource "aws_subnet" "main" {
  for_each   = var.subnets
  vpc_id     = aws_vpc.main[each.value.vpc_key].id
  cidr_block = each.value.cidr_block
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = each.key
  }
}

# Create Internet Gateways
resource "aws_internet_gateway" "main" {
  for_each = var.internet_gateways
  vpc_id   = aws_vpc.main[each.value.vpc_key].id

  tags = {
    Name = each.key
  }
}

# Create Route Tables
resource "aws_route_table" "main" {
  for_each = var.route_tables
  vpc_id   = aws_vpc.main[each.value.vpc_key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[each.value.gateway_key].id
  }

  tags = {
    Name = each.key
  }
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "main" {
  for_each = var.subnets
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main[each.value.route_table_key].id
}

# Create VPC Peering Connections
resource "aws_vpc_peering_connection" "main" {
  for_each = var.peering_connections
  vpc_id      = aws_vpc.main[each.value.requester_vpc_key].id
  peer_vpc_id = aws_vpc.main[each.value.accepter_vpc_key].id
  auto_accept = each.value.auto_accept

  tags = {
    Name = each.key
  }
}

# Create EC2 Instances
resource "aws_instance" "main" {
  for_each = var.subnets
  ami           = "ami-08a52ddb321b32a8c"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.main[each.key].id
  vpc_security_group_ids = [aws_security_group.main[each.value.vpc_key].id]

  tags = {
    Name = "MyInstance-${each.key}"
  }
}

resource "aws_security_group" "main" {
  for_each = var.vpcs
  name        = "ssh-access-sg-${each.key}"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main[each.key].id

  ingress {
    description = "SSH from specific IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [each.value.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH Access Security Group - ${each.key}"
  }
}