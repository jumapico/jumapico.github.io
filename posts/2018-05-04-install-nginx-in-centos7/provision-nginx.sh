#!/bin/bash
#
# Install nginx and configure it to serve the content of the root directory.
#
set -e
set -x

echo 'Check params'
if [ -z ${SERVER_DOMAIN} ]; then
    echo 'SERVER_DOMAIN envvar not defined'
    exit 1
fi
if [ -z ${ROOT_DIRECTORY} ]; then
    echo 'ROOT_DIRECTORY envvar not defined'
    exit 1
fi

echo 'Install nginx'
yum -y install epel-release
yum -y update
yum -y install nginx

echo 'Configure nginx'
cat <<END > /etc/nginx/conf.d/${SERVER_DOMAIN}.conf
server {
    listen 80;
    server_name ${SERVER_DOMAIN};
    root ${ROOT_DIRECTORY};
    autoindex on;
}
END

echo 'Enable and start nginx'
systemctl enable nginx.service
systemctl start nginx.service

echo 'Configure firewall'
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload

echo 'Done'
