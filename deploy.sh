#!/bin/bash
sudo yum update && sudo yum upgrade -y
sudo yum -y install java-1.7.0-openjdk-devel tomcat tomcat-webapps tomcat-admin-webapps httpd http-devel mod_proxy_html mod_ssl php php-gd php-common php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-soap curl curl-devel unzip pip git curl wget maven epel-release python-pip awscli gcc nano svn vim
sudo systemctl start httpd
sudo systemctl enable httpd
sudo echo "Hello, World" > /var/www/html/index.html
sudo echo "<?php phpinfo(); ?>" > /var/www/html/info.php
publicip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4) 
echo "Redirect   / http://"$publicip":8080/java-examples-tomcat" >> /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd
sudo systemctl start tomcat
sudo systemctl enable tomcat
sudo sudo ln -s /var/lib/tomcat/webapps /etc/tomcat/
cd /var/lib/tomcat/webapps && sudo git clone https://github.com/jalcalaroot/java-examples-tomcat.git
sudo systemctl restart tomcat
EOF
