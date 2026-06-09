terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" { # virtual private cloud is a logically isolated section of the AWS cloud where you can launch AWS resources in a virtual network that you define. You have complete control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways.
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" { # private subnet for instances that should have direct access to the internet, will use nat gateway in public subnet to access the internet
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" { # private subnet for instances that should not have direct access to the internet, will use nat gateway in public subnet to access the internet
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "igw" { # need this for gateway to the internet for public subnet and nat gateway
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public" { # need this so public subnet can access the internet 
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public" { # associate public subnet with public route table so it can access the internet
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_eip" "nat" { # need this for nat gateway to have a public IP address so it can access the internet for private subnet
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" { # middle man for private subnet to access the internet, will be in public subnet and use elastic IP address to access the internet
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" { # need this so private subnet can access the internet through nat gateway
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "public_sg" { # security group for public subnet
  name   = "public-sg"
  vpc_id = aws_vpc.main.id
  #przychodzace
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # wychodzace
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "public-sg"
  }
}

resource "aws_security_group" "private_sg" {
  name   = "private-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { # icmp from vpc 
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private-sg"
  }
}

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    from_port  = 22
    to_port    = 22
    cidr_block = "0.0.0.0/0"
  }
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
  }
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
  }
  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }
  ingress {
    rule_no    = 140
    protocol   = "icmp"
    action     = "allow"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }
  egress {
    rule_no    = 150
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }
  egress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "public-nacl"
  }
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private.id]

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }
  ingress {
    rule_no    = 140
    protocol   = "icmp"
    action     = "allow"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }


  tags = {
    Name = "private-nacl"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "public_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  key_name               = "MyKey"
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  tags = {
    Name = "public-instance"
  }
}

resource "aws_instance" "private_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  key_name               = "MyKey"
  depends_on             = [aws_nat_gateway.nat]
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "private-instance"
  }
}

output "public_ec2_ip" {
  value = aws_instance.public_instance.public_ip
}

output "private_ec2_ip" {
  value = aws_instance.private_instance.private_ip
}

output "nat_gateway_ip" {
  value = aws_eip.nat.public_ip
}
