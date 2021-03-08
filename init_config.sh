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
CREATE USER 'pgv'@'%' IDENTIFIED WITH pgvpwd BY 'pgv';
GRANT ALL ON pgvdb.* TO 'pgv'@'%';
EOF

# Test the config
mysql -u pgv -ppgvpwd << EOF
SHOW DATABASES;
EOF

# PHP installation
apt-get install php libapache2-mod-php php-mysql php-xml php-xml-htmlsax3 php-xmlrpc -y
apt-get install php7.4-gd -y
php -v

# Fixing an apache error
echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf
systemctl restart apache2.service

# PhpGed View installation
GEDVIEW_DIR=/var/www/pgv
mkdir $GEDVIEW_DIR
wget https://sourceforge.net/code-snapshots/svn/p/ph/phpgedview/svn/phpgedview-svn-r7290-trunk-phpGedView.zip
unzip phpgedview-svn-r7290-trunk-phpGedView.zip $GEDVIEW_DIR/
cp $GEDVIEW_DIR/config.dist $GEDVIEW_DIR/config.php

# Bug fix
wget https://sourceforge.net/p/phpgedview/discussion/185166/thread/6ddd158/1a5/2bac/attachment/functions_mediadb.php
cp functions_mediadb.php $GEDVIEW_DIR/includes/functions/

# Permissions
chmod -R 755 $GEDVIEW_DIR
chmod -R 777 $GEDVIEW_DIR/index
chmod -R 777 $GEDVIEW_DIR/config.php
chmod -R 777 $GEDVIEW_DIR/languages
chmod 777 $GEDVIEW_DIR/media
chmod 777 $GEDVIEW_DIR/media/thumbs
