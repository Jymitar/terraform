#Output webserver public IP address

output "web_app_public_ip" {
  value = aws_instance.app-web.public_ip
}
