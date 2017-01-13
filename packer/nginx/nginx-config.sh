#!/bin/bash
setenforce 0
TMPL_TEXT="omega"
AWS_BUCKET=""
user_data_params=$(curl http://169.254.169.254/latest/user-data)
eval "${user_data_params}"
aws --region=eu-central-1 s3 sync "s3://${AWS_BUCKET}" /srv/www
sed -i "s/%TMPL_TEXT%/${TMPL_TEXT}/" /srv/www/index.html
tee /etc/nginx/nginx.conf <<EOF
user  nginx;

worker_processes  1;

error_log  /srv/logs/error.log;

pid        /srv/logs/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /srv/logs/access.log  main;
    error_log /srv/logs/error.log;
    sendfile        on;
    tcp_nopush     on;
    keepalive_timeout  65;
    gzip  on;

    server {
        listen       80;
        server_name  localhost;
        charset utf8;
        access_log  /srv/logs/host.access.log  main;
        location / {
            #The location setting lets you configure how nginx responds to requests for resources within the server.
            root   /srv/www;
            index  index.html;
        }
    }
}
EOF
