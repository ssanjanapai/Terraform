provider "aws" {
  region     = var.region
  access_key = "AKIAT7O2QQPVLAQHDOFN"
  secret_key = "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"
}



resource "aws_vpc" "prod-vpc" {
  cidr_block       = var.cidr
  tags={
      Name="production"
  }
  }

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}

resource "aws_route_table" "prod-route-table" {
  vpc_id =aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod"
  }
}
resource "aws_subnet""subnet1"{
    vpc_id =aws_vpc.prod-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone="ap-south-1a"
    tags={
        Name="prod-sunet"
    }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_all]
  }
  ingress {
    description = "HTTP "
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_all]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_all]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_all]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_network_interface" "webserver-nic" {
  subnet_id       = aws_subnet.subnet1.id
  private_ips     = ["10.0.0.50"]
  security_groups = [aws_security_group.allow_web.id]
}
resource "aws_eip" "lb" {
  vpc      = true
  network_interface=aws_network_interface.webserver-nic.id
  associate_with_private_ip="10.0.0.50"
  depends_on=[aws_internet_gateway.gw]
}

resource "aws_instance" "webserver-instance"{
    ami="ami-0e306788ff2473ccb"
    instance_type="t2.micro"
    availability_zone="ap-south-1a"
    key_name="bchaindynamics-new"
    network_interface{
        device_index=0
        network_interface_id=aws_network_interface.webserver-nic.id

    }
    user_data= <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo bash -c 'echo my very fisrt web server>/var/www/html/index.html'
    EOF
    tags={
        Name="web-server"

    }
}