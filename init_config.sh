#!/bin/bash


# Firewall init
ufw app list
ufw allow OpenSSH
ufw --force enable
ufw status

# Apache installation
apt-get update && apt-get upgrade -y
apt-get install curl zip unzip apache2 -y
ufw allow in "Apache"

# MySQL installation
apt-get -y install mysql-server
mysql_secure_installation <<EOF
n
admin
admin
y
y
y
y
y
EOF

# MySQL config
mysql -pubuntuadmin << EOF
CREATE DATABASE pgvdb;
CREATE USER 'pgv'@'localhost' IDENTIFIED BY 'pgv';
GRANT ALL PRIVILEGES ON pgvdb.* TO 'pgv'@'localhost';
FLUSH PRIVILEGES;
EOF

# Test the config
mysql -u pgv -ppgv << EOF
SHOW DATABASES;
EOF

# PHP installation
apt-get install php libapache2-mod-php php-mysql php-xml php-xml-htmlsax3 php-xmlrpc -y
apt-get install php7.4-gd -y
php -v

# Config apache
GEDVIEW_DIR=/var/www/pgv
mkdir $GEDVIEW_DIR
MYUSER=ubuntu
chown -R $MYUSER:$MYUSER $GEDVIEW_DIR
cat << EOF > /etc/apache2/sites-available/pgv.conf 
<VirtualHost *:80>
    # ServerName pgv
    # ServerAlias www.pgv
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/pgv
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
a2ensite pgv
a2dissite 000-default
apache2ctl configtest
line="ServerName 127.0.0.1"
[ "`tail -1 /etc/apache2/apache2.conf`" != "$line" ] && echo $line >> /etc/apache2/apache2.conf
systemctl reload apache2.service

# PhpGed View installation
ZIPFILENAME=phpgedview.zip 
wget -O $ZIPFILENAME https://sourceforge.net/projects/phpgedview/files/latest/download
unzip -o $ZIPFILENAME -d $GEDVIEW_DIR

# Bug fix
wget -O functions_mediadb.php https://sourceforge.net/p/phpgedview/svn/HEAD/tree/trunk/phpGedView/includes/functions/functions_mediadb.php?format=raw
cp functions_mediadb.php $GEDVIEW_DIR/includes/functions/

# Permissions
chmod -R 755 $GEDVIEW_DIR
chmod -R 777 $GEDVIEW_DIR/index
chmod -R 777 $GEDVIEW_DIR/config.php
chmod -R 777 $GEDVIEW_DIR/languages
chmod 777 $GEDVIEW_DIR/media
chmod 777 $GEDVIEW_DIR/media/thumbs
