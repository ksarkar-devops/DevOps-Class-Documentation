terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.13.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Change this to your desired region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"  # Replace with your desired CIDR block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "my_subnet" {
  count = 2

  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.${count.index}.0/24"  # Adjust CIDR blocks for each subnet

  availability_zone = "us-east-1a"  # Replace with desired availability zone

  map_public_ip_on_launch = true

  tags = {
    Name = "MySubnet-${count.index}"
  }
}

resource "aws_instance" "my_instances" {
  count = 2

  ami           = "ami-08a52ddb321b32a8c"  # Replace with your desired AMI ID
  instance_type = "t3.micro"  # Replace with your desired instance type
  subnet_id     = aws_subnet.my_subnet[count.index].id

  tags = {
    Name = "MyInstance-${count.index}"
  }
}
