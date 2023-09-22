#!/bin/bash

# Ubuntu 22.04 - wait on cloud-init to complete before proceeding with provisioning.
echo "waiting 180 seconds for cloud-init to update /etc/apt/sources.list"
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting ...; sleep 1; done'
# Ubuntu 22.04 - stopping "Daemons using outdated libraries" message
sudo sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

# Updating repository
sudo apt-get update

# To install all prerequests for Wordpress:
sudo apt install apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip -y

# Create the installation directory and download the file from WordPress.org:
sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
            
# Create Apache site for WordPress. 
sudo cat > /tmp/wordpress.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo cp /tmp/wordpress.conf /etc/apache2/sites-available/wordpress.conf

# Enable the site with:
sudo a2ensite wordpress
# Enable URL rewriting with:
sudo a2enmod rewrite
# Disable the default "It Works" site with:
sudo a2dissite 000-default

# Configure database
sudo mysql -u root -e 'CREATE DATABASE wordpress;'
sudo mysql -u root -e 'CREATE USER wordpress@localhost IDENTIFIED BY "fr0s7f1r3";'
sudo mysql -u root -e 'GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;'
sudo mysql -u root -e 'FLUSH PRIVILEGES;'

# Configure WordPress to connect to the database
sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/fr0s7f1r3/' /srv/www/wordpress/wp-config.php

# Restart web and db services:
sudo systemctl restart mysql
sudo systemctl restart apache2