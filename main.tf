terraform {
  backend "s3" {
    bucket = "akshath-bucket"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}
provider "aws" {
  region = "us-east-1"
}

# Data source to get the latest Amazon Linux 2 AMI ID
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my_vpc"
  }
}

# Create a subnet
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "my_subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

# Create a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_route_table"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "my_route_table_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create a security group
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
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
    Name = "my_security_group"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "akira"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOiAGKuE0PUoxdiQWRnBrUFAj/FMGMIO4ZoNoVwWxbq0q1F1DjY0reMvO/cNMmyvr7+24Unx7z7GV/M08uwacXfs1nZ21mZ8KBxitExOkwdpxQBSnFhvwzhPvGhZ+bEp3SZ2E5MaEUgC8dqhkHPsLLcqiMOH60evSGsTe4KzjxnLt+F5X6zI3RY5q0mywepgapuTuq0WPLQ4/ig9MtjxTYay77WCZwu+TIi4knLSVNR2Bvwp4TJFyDd4owTfiFztHelXeSUsMiYIc7vAFqCUBC8Ep0mhm7nCuyjOAYN903pYt65+oFkzMaQ2TbsDI0aGtICg6nKRIAhz+sfrbkQOu0JJFHv6AQZOV0QuEcFORlQxnAK5fedlB6vhv60nLB2RqEGIP7+DQUxusiXd7kq6KSYMMjmhcoVHRDTgwYKacoxu2uJZ4qS8sECGupT5xFNS8qoJcsquoVL1yrA4Nz4EdAiKpVqBBes020X84cMvOyKAgFRc/r89T2xK8XEQJvq5M= akhiljahagirdar@akhils-MacBook-Pro.local"
}

# Launch an EC2 instance
resource "aws_instance" "web" {
  ami                    = "ami-06c68f701d8090592"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  key_name               = "akira"  # Replace with your key pair name


  associate_public_ip_address = true

  tags = {
    Name = "iverson_server"
  }
}
