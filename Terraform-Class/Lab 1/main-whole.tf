# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create first VPC
resource "aws_vpc" "vpc1" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-1"
  }
}

# Create first subnet in VPC1
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-1"
  }
}

# Create internet gateway for VPC1
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "igw-1"
  }
}

# Create route table for VPC1
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  route {
    cidr_block                = "10.2.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name = "rt-1"
  }
}

# Associate route table with subnet1
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

# Create second VPC
resource "aws_vpc" "vpc2" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-2"
  }
}

# Create second subnet in VPC2
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-2"
  }
}

# Create internet gateway for VPC2
resource "aws_internet_gateway" "igw2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "igw-2"
  }
}

# Create route table for VPC2
resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw2.id
  }

  route {
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name = "rt-2"
  }
}

# Associate route table with subnet2
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt2.id
}

# Create VPC peering connection
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id = aws_vpc.vpc1.id
  vpc_id      = aws_vpc.vpc2.id
  auto_accept = true

  tags = {
    Name = "vpc-peering-1-2"
  }
}

# Security group for EC2 instances (allows SSH)
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-ssh-sg"
  description = "Allow SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-ssh-sg"
  }
}

# EC2 instance in first subnet
resource "aws_instance" "ec2_1" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 in us-east-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "ec2-instance-1"
  }
}

# EC2 instance in second subnet
resource "aws_instance" "ec2_2" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 in us-east-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "ec2-instance-2"
  }
}

# Output the important information
output "vpc1_id" {
  value = aws_vpc.vpc1.id
}

output "vpc2_id" {
  value = aws_vpc.vpc2.id
}

output "ec2_1_public_ip" {
  value = aws_instance.ec2_1.public_ip
}

output "ec2_2_public_ip" {
  value = aws_instance.ec2_2.public_ip
}

output "peering_connection_id" {
  value = aws_vpc_peering_connection.peer.id
}