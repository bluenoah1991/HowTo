#!/bin/bash

CTL_HOST=controller

apt-get install openstack-dashboard apache2 libapache2-mod-wsgi memcached python-memcache -y

echo "ServerName localhost:80" >> /etc/apache2/apache2.conf

sed -i "/^OPENSTACK_HOST/cOPENSTACK_HOST = \"${CTL_HOST}\"" /etc/openstack-dashboard/local_settings.py

service apache2 restart
service memcached restart
