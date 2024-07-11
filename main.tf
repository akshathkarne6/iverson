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
  key_name   = "apache"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDE2qjAj1jy0Uab1fvwEE3BO2iDg7Zu3iyfaZOvhQbp8CM1ofDGOIEjqY++/SLxYSrD4OPRixSk2BrOjZpdZsJ5Gm8uKNx+mFqtVR1pce+GhcwXi2t0pCBliRzh/fVDSjwjHuZ8qTewsTj9y/Arg8wDlde9SdTtJbjqS9hmSy3R/40f8MF1xffKmxzGZ3/x+GxwPpFPIyuKZESBOMdv4ZdRPEmknsZgDUbOeGyNQbiPGIBDGcr2xoE1xpUmbZjLSHEluRbLX4KGimmkIJWeEpINzxK3ZTWqhfPhi4rYmnZcMhH/JN7xCuB59Ged1ar2yYv6QenrorFdPhz3SvksetmuGupMZaNdXnCNSDLoZjjt8NxHhovajjhCK4ZTqkMO3/BS9uJ7YynLM8JseWc9TkOzkYAkOi9ir3jEEan+vULEJrAzqbv0h+z3nHM9NOj7gp32sppK2epkb3wHhXija3xR1f2dZQVUxOdvanKyF7uZn3peBFIHL5w29Q1Mhwwila8= akhiljahagirdar@akhils-MacBook-Pro.local"
}

# Launch an EC2 instance
resource "aws_instance" "web" {
  ami                    = "ami-06c68f701d8090592"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  key_name               = "apache"  # Replace with your key pair name

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = "${aws_instance.web.public_ip}"
    private_key = file("apache")
  }
  
  provisioner "file" {
    source      = "apache_install_.sh"
    destination = "/tmp/apache_install_.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/apache_install_.sh",
      "/tmp/apache_install_.sh",
    ]
  }

  associate_public_ip_address = true

  tags = {
    Name = "iverson_"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}