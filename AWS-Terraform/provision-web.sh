#!/bin/bash

# Install the required packages
sudo yum install -y httpd php php-mysqlnd git 

# Switch the SELinux to permissive mode
sudo setenforce 0

# Enable and start the Apache2 service
sudo systemctl enable --now httpd

# Download the project
git clone https://github.com/Jymitar/bgapp

# Copy the files related to the web application
sudo cp ~/bgapp/web/* /var/www/html

# Substitute MariaDB related connection parameters
sudo sed -i 's/db/10.10.10.101/g' /var/www/html/config.php
