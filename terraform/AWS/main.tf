terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.49.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region              = "ap-southeast-1"
  allowed_account_ids = ["853107954831"]
}

resource "aws_key_pair" "deployer" {
  key_name   = "amitsh-key"
  public_key = var.my-ssh-key
}


# Create a VPC
resource "aws_vpc" "boiler_plate_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name  = "boiler_plate_vpc"
    Owner = "ash"
  }
}

resource "aws_subnet" "private-subnet-a" {
  vpc_id     = aws_vpc.boiler_plate_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "public-subnet-a" {
  vpc_id                  = aws_vpc.boiler_plate_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "private-subnet-b" {
  vpc_id     = aws_vpc.boiler_plate_vpc.id
  cidr_block = "10.0.11.0/24"

  tags = {
    Name = "private-subnet-b"
  }
}

resource "aws_subnet" "public-subnet-b" {
  vpc_id     = aws_vpc.boiler_plate_vpc.id
  cidr_block = "10.0.12.0/24"

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.boiler_plate_vpc.id
  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "vpc_route_table-pub" {
  vpc_id = aws_vpc.boiler_plate_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "pub-rt"
  }
}

resource "aws_route_table" "vpc_route_table-prv" {
  vpc_id = aws_vpc.boiler_plate_vpc.id

  tags = {
    Name = "prv-rt"
  }
}


resource "aws_route_table_association" "pub-a" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.vpc_route_table-pub.id
}

resource "aws_route_table_association" "pub-b" {
  subnet_id      = aws_subnet.public-subnet-b.id
  route_table_id = aws_route_table.vpc_route_table-pub.id
}

resource "aws_route_table_association" "prv-a" {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.vpc_route_table-prv.id
}

resource "aws_route_table_association" "prv-b" {
  subnet_id      = aws_subnet.private-subnet-b.id
  route_table_id = aws_route_table.vpc_route_table-prv.id
}

data "aws_ami" "cldcvr_image" {
  most_recent = true
  owners      = ["571467501391"] # CldCvr
  filter {
    name   = "name"
    values = ["cldcvr-ubuntu-2004-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_security_group" "private_security_group" {
  name        = "private-security-group"
  description = "Allow traffic for private instances"
  vpc_id      = aws_vpc.boiler_plate_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.boiler_plate_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "private-security-group"
  }
}

resource "aws_security_group" "public_security_group" {
  name        = "public-security-group"
  description = "Allow traffic for public instances"
  vpc_id      = aws_vpc.boiler_plate_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.boiler_plate_vpc.cidr_block]
  }
  ingress {
    description      = "TLS from Internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description = "SSH from IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "public-security-group"
  }
}


resource "aws_network_interface" "private-network-interface" {
  subnet_id       = aws_subnet.private-subnet-a.id
  security_groups = [aws_security_group.private_security_group.id]
}

resource "aws_network_interface" "public-network-interface" {

  subnet_id       = aws_subnet.public-subnet-a.id
  security_groups = [aws_security_group.public_security_group.id]
}
resource "aws_instance" "public_instances" {
  count = var.instance_count_pub

  ami           = data.aws_ami.cldcvr_image.id
  instance_type = var.instance_type
  network_interface {
    network_interface_id = aws_network_interface.public-network-interface.id
    device_index         = 0
  }
  key_name  = aws_key_pair.deployer.key_name
  user_data = <<EOF
      #! /bin/bash
      sudo apt update
      sudo apt-get install -y nginx
  EOF

  tags = {
    Name = "public-instance-${count.index}"
  }
}


resource "aws_instance" "private_instances" {
  count = var.instance_count_prv

  ami           = data.aws_ami.cldcvr_image.id
  instance_type = var.instance_type
  network_interface {
    network_interface_id = aws_network_interface.private-network-interface.id
    device_index         = 0
  }
  key_name  = aws_key_pair.deployer.key_name
  user_data = <<EOF
      #! /bin/bash
      sudo apt update
      sudo apt-get install -y nginx
  EOF

  tags = {
    Name = "private-instance-${count.index}"
  }
}