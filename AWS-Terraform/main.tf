provider "aws" {
  access_key = var.v-access-key
  secret_key = var.v-secret-key
  region     = var.region
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
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.10.10.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "app-web-net" {
  subnet_id       = aws_subnet.web-snet.id
  private_ips     = ["10.10.10.100"]
  security_groups = [aws_security_group.web-pub-sg.id]

  tags = {
    Name = "APP-WEB-PRIVATE-IP"
  }
}

resource "aws_network_interface" "db-web-net" {
  subnet_id       = aws_subnet.web-snet.id
  private_ips     = ["10.10.10.101"]
  security_groups = [aws_security_group.web-pub-sg.id]

  tags = {
    Name = "DB-WEB-PRIVATE-IP"
  }
}

resource "aws_instance" "app-web" {
  ami           = var.v-ami-image
  instance_type = var.v-instance-type
  key_name      = var.v-instance-key
  tags = {
    Name = "WEB"
  }

  network_interface {
    network_interface_id = aws_network_interface.app-web-net.id
    device_index         = 0
  }

  provisioner "file" {
    source      = "./provision-web.sh"
    destination = "/tmp/provision-web.sh"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("keypairname.pem")
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-web.sh",
      "/tmp/provision-web.sh"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("keypairname.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "db-web" {
  ami           = var.v-ami-image
  instance_type = var.v-instance-type
  key_name      = var.v-instance-key
  tags = {
    Name = "DB"
  }

  network_interface {
    network_interface_id = aws_network_interface.db-web-net.id
    device_index         = 0
  }

  provisioner "file" {
    source      = "./provision-db.sh"
    destination = "/tmp/provision-db.sh"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("keypairname.pem")
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-db.sh",
      "/tmp/provision-db.sh"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("keypairname.pem")
      host        = self.public_ip
    }
  }
}

output "web_app_public_ip" {
  value = aws_instance.app-web.public_ip
}
