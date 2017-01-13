#!/bin/bash -ex
echo "**********************************************************************************"
echo "Instalation of nginx"
yum install -y epel-release
yum install -y nginx awscli
mkdir -p /srv/www
mkdir -p /srv/logs
chown nginx:nginx /srv/logs /srv/www
mkdir -p /usr/local/nginx
mv /tmp/nginx-config.sh /usr/local/nginx/nginx-config.sh
chown root:root /usr/local/nginx/nginx-config.sh
chmod 0755 /usr/local/nginx/nginx-config.sh
mv /tmp/nginx.service /lib/systemd/system/nginx.service
chown root:root /lib/systemd/system/nginx.service
chmod 0644 /lib/systemd/system/nginx.service
systemctl enable nginx
