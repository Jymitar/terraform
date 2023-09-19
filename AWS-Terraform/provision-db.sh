#!/bin/bash

# Install the required packages
sudo yum install -y mariadb mariadb-server git

# Configure MariaDB to listen on all interfaces
echo 'bind-address = 0.0.0.0' | sudo tee -a /etc/my.cnf.d/server.cnf

# Enable and start the MariaDB service
sudo systemctl enable --now mariadb

# Download the project
git clone https://github.com/Jymitar/bgapp

# Install the database required for the web application
sudo mysql -u root < ~/bgapp/db/db_setup.sql