#!/bin/bash

KEYSTONEPWD=123456 
CTL_IPADDR=10.0.0.11
ADMIN_PASS=123456
EMAIL_ADDRESS=admin@linkgent.com
DEMO_PASS=123456
DEMO_EMAIL_ADDRESS=demo@linkgent.com

echo 'Please tell me your MariaDB password:'
read MARIADBPWD

sql1="
  GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' 
  IDENTIFIED BY '${KEYSTONEPWD}'
"
sql2="
  GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' 
  IDENTIFIED BY '${KEYSTONEPWD}'
"

mysql -uroot -p${MARIADBPWD} << EOF

CREATE DATABASE keystone;

${sql1};
${sql2};

EOF

RANDPWD=`openssl rand -hex 10`

apt-get install keystone python-keystoneclient -y

cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.bak

sed -i "/^#admin_token/cadmin_token = ${RANDPWD}" /etc/keystone/keystone.conf
sed -i "/^connection=/cconnection = mysql://keystone:${KEYSTONEPWD}@${CTL_IPADDR}/keystone" \
/etc/keystone/keystone.conf
sed -i "/^#provider=/cprovider = keystone.token.providers.uuid.Provider" /etc/keystone/keystone.conf
sed -i "/^#driver=keystone.token.persistence.backends.sql.Token/s/#//" /etc/keystone/keystone.conf
sed -i "/^#driver=keystone.contrib.revoke.backends.sql.Revoke/s/#//" /etc/keystone/keystone.conf
sed -i "/^#verbose=false/cverbose = True" /etc/keystone/keystone.conf

su -s /bin/sh -c "keystone-manage db_sync" keystone

service keystone restart
rm -f /var/lib/keystone/keystone.db

export OS_SERVICE_TOKEN=${RANDPWD}
export OS_SERVICE_ENDPOINT=http://${CTL_IPADDR}:35357/v2.0

keystone tenant-create --name admin --description "Admin Tenant"
keystone user-create --name admin --pass ${ADMIN_PASS} --email ${EMAIL_ADDRESS}
keystone role-create --name admin
keystone user-role-add --user admin --tenant admin --role admin
keystone tenant-create --name demo --description "Demo Tenant"
keystone user-create --name demo --tenant demo --pass ${DEMO_PASS} --email ${DEMO_EMAIL_ADDRESS}
keystone tenant-create --name service --description "Service Tenant"
keystone service-create --name keystone --type identity --description "OpenStack Identity"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ identity / {print $2}') \
  --publicurl http://${CTL_IPADDR}:5000/v2.0 \
  --internalurl http://${CTL_IPADDR}:5000/v2.0 \
  --adminurl http://${CTL_IPADDR}:35357/v2.0 \
  --region regionOne

echo "
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=${ADMIN_PASS}
export OS_AUTH_URL=http://${CTL_IPADDR}:35357/v2.0
" > /root/admin-openrc.sh

echo "
export OS_TENANT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=${DEMO_PASS}
export OS_AUTH_URL=http://${CTL_IPADDR}:5000/v2.0
" > /root/demo-openrc.sh

