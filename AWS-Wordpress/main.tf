provider "aws" {
  access_key = "<Your Access Key>"
  secret_key = "<Your secret Key>"
  region     = "eu-central-1"
}

resource "aws_vpc" "web-vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "WEB-VPC"
  }
}

resource "aws_internet_gateway" "web-igw" {
  vpc_id = aws_vpc.web-vpc.id
  tags = {
    Name = "WEB-IGW"
  }
}

resource "aws_route_table" "web-public" {
  vpc_id = aws_vpc.web-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web-igw.id
  }
  tags = {
    Name = "WEB-PUBLIC"
  }
}

resource "aws_subnet" "web-snet" {
  vpc_id                  = aws_vpc.web-vpc.id
  cidr_block              = "10.10.10.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "WEB-SUB-NET"
  }
}

resource "aws_route_table_association" "web-public-assoc" {
  subnet_id      = aws_subnet.web-snet.id
  route_table_id = aws_route_table.web-public.id
}

resource "aws_security_group" "web-pub-sg" {
  name        = "web-pub-sg"
  description = "WEB Public SG"
  vpc_id      = aws_vpc.web-vpc.id
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "wp-web-net" {
  subnet_id       = aws_subnet.web-snet.id
  private_ips     = ["10.10.10.100"]
  security_groups = [aws_security_group.web-pub-sg.id]

  tags = {
    Name = "WP-WEB-PRIVATE-IP"
  }
}

resource "aws_instance" "wp-web" {
  ami           = "ami-04e601abe3e1a910f"
  instance_type = "t2.micro"
  key_name      = "your key pair"
  tags = {
    Name = "WORDPRESS"
  }

  network_interface {
    network_interface_id = aws_network_interface.wp-web-net.id
    device_index         = 0
  }

  provisioner "file" {
    source      = "./provision-wordpress.sh"
    destination = "/tmp/provision-wordpress.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("<your key pair.pem>")
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-wordpress.sh",
      "/tmp/provision-wordpress.sh"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("<your key pair.pem>")
      host        = self.public_ip
    }
  }
}

output "wp_web_public_ip" {
  value = aws_instance.wp-web.public_ip
}
