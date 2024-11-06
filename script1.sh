#!/bin/bash

# Ensure OS updated

sudo yum update -y && sudo yum upgrade -y

# Ensure apache

sudo yum install httpd httpd-tools -y

# Enabling apache

sudo systemctl start httpd
sudo systemctl enable httpd
sudo firewall-cmd --add-service=ssh --permanent
sudo firewall-cmd --add-sevice=http --permanent
sudo firewall-cmd --add-port=3306/tcp --permanent
sudo firewall-cmd --reload

# PHP e extensões para Worpress

php-bcmath php-gd php-soap php-curl php-mbstring php-mysqlnd php-gd php-xml php-intl php-zip

# Ensure MariaDB

sudo systemctl enable mariadb
sudo systemctl start mariadb

# Database Mariabd

echo "database access"
root_password=root

#sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('$root_password') WHERE User = 'root'"

echo "Creating wordpress database" 
sudo mysql -e "CREATE DATABASE IF NOT EXISTS wordpress"
echo "Creating user"
sudo mysql -e "CREATE USER IF NOT EXISTS 'marcella'@'localhost' IDENTIFIED BY 'root'";
echo "Grant all on"
udo mysql -e "GRANT ALL ON wordpress.* TO 'marcella'@'localhost'";
echo "flush"
sudo mysql -e "FLUSH PRIVILEGES";


# Ensure Wordpress

wget https://wordpress.org/latest.zip
unzip latest.zip -d /var/www/html/
chown -R apache:apache /var/www/htmk/wordpress/
chcon -t httpd_sys_rw_content_t /var/www/html/wordpress -R



# Apache to Wordpress

cat <<EOL | sudo tee /etc/httpd/conf.d/wordpress.conf
<VirtualHost *:80>

        ServerAdmin webmaster@your-domain.com
        ServerName your-domain.com
        ServerAlias www.your-domain.com
        DocumentRoot $wordpress_path
        <Directory $wordpress_path>
                Options FollowSymlinks
                AllowOverride All
                Require all ranted
        </Directory>

        ErrorLog /var/log/httpd/your-domain.com_error.log
        CustomLog /var/log/httpd/your-domain.com_access.log combined

</VirtualHost>
EOL

systemctl restat httpd

