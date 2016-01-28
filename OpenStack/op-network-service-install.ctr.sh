#!/bin/bash

NEUTRON_DBPASS=123456 
CTL_HOST=controller
ADMIN_PASS=123456
NEUTRON_PASS=123456 
RABBIT_PASS=123456 # from rabbit mq
NOVA_PASS=123456 # from compute service

echo 'Please tell me your MariaDB password:'
read MARIADBPWD

sql1="
  GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' 
  IDENTIFIED BY '${NEUTRON_DBPASS}'
"
sql2="
  GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' 
  IDENTIFIED BY '${NEUTRON_DBPASS}'
"

mysql -uroot -p${MARIADBPWD} << EOF

CREATE DATABASE neutron;

${sql1};
${sql2};

EOF

export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=${ADMIN_PASS}
export OS_AUTH_URL=http://${CTL_HOST}:35357/v2.0

keystone user-create --name neutron --pass ${NEUTRON_PASS}
keystone user-role-add --user neutron --tenant service --role admin
keystone service-create --name neutron --type network \
  --description "OpenStack Networking"
keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ network / {print $2}') \
  --publicurl http://${CTL_HOST}:9696 \
  --adminurl http://${CTL_HOST}:9696 \
  --internalurl http://${CTL_HOST}:9696 \
  --region regionOne

apt-get install neutron-server neutron-plugin-ml2 python-neutronclient -y

sed -i "/^connection/cconnection = mysql://neutron:${NEUTRON_DBPASS}@${CTL_HOST}/neutron" /etc/neutron/neutron.conf
sed -i "/^#rpc_backend=rabbit/s/#//" /etc/neutron/neutron.conf
sed -i "/^#rabbit_host=localhost/crabbit_host = ${CTL_HOST}" /etc/neutron/neutron.conf
sed -i "/^#rabbit_password=guest/crabbit_password = ${RABBIT_PASS}" /etc/neutron/neutron.conf
sed -i "/^# auth_strategy/s/# //" /etc/neutron/neutron.conf
sed -i "/^auth_host/s/^/#/" /etc/neutron/neutron.conf
sed -i "/^auth_port/s/^/#/" /etc/neutron/neutron.conf
sed -i "/^auth_protocol/s/^/#/" /etc/neutron/neutron.conf
ln_keystone_authtoken=`grep -n '^\[keystone_authtoken\]' /etc/neutron/neutron.conf | head -1 | cut -d : -f 1`
sed -i "${ln_keystone_authtoken}a\\
auth_uri = http://${CTL_HOST}:5000/v2.0\\
identity_uri = http://${CTL_HOST}:35357" /etc/neutron/neutron.conf
sed -i "/^admin_tenant_name/cadmin_tenant_name = service" /etc/neutron/neutron.conf
sed -i "/^admin_user/cadmin_user = neutron" /etc/neutron/neutron.conf
sed -i "/^admin_password/cadmin_password = ${NEUTRON_PASS}" /etc/neutron/neutron.conf
sed -i "/^# service_plugins/cservice_plugins = router" /etc/neutron/neutron.conf
sed -i "/^# allow_overlapping_ips/callow_overlapping_ips = True" /etc/neutron/neutron.conf
sed -i "/^# notify_nova_on_port_status_changes = True/s/# //" /etc/neutron/neutron.conf
sed -i "/^# notify_nova_on_port_data_changes = True/s/# //" /etc/neutron/neutron.conf
sed -i "/^# nova_url/cnova_url = http://${CTL_HOST}:8774/v2" /etc/neutron/neutron.conf
sed -i "/^# nova_admin_auth_url/cnova_admin_auth_url = http://${CTL_HOST}:35357/v2.0" /etc/neutron/neutron.conf
sed -i "/^# nova_region_name/cnova_region_name = regionOne" /etc/neutron/neutron.conf
sed -i "/^# nova_admin_username/cnova_admin_username = nova" /etc/neutron/neutron.conf
SERVICE_TENANT_ID=`keystone tenant-get service | grep id | cut -d '|' -f 3 | awk '{print $1}'`
sed -i "/^# nova_admin_tenant_id/cnova_admin_tenant_id = ${SERVICE_TENANT_ID}" /etc/neutron/neutron.conf
sed -i "/^# nova_admin_password/cnova_admin_password = ${NOVA_PASS}" /etc/neutron/neutron.conf
sed -i "/^# verbose = False/cverbose = True" /etc/neutron/neutron.conf

# To Configure the Modular Layer 2 plug-in

sed -i "/^# type_drivers/ctype_drivers = flat,gre" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# tenant_network_types/ctenant_network_types = gre" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# mechanism_drivers/cmechanism_drivers = openvswitch" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# tunnel_id_ranges/ctunnel_id_ranges = 1:1000" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# enable_security_group/s/# //" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# enable_ipset/s/# //" /etc/neutron/plugins/ml2/ml2_conf.ini
echo "firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver" >> /etc/neutron/plugins/ml2/ml2_conf.ini

# To configure Compute to use Networking

ln_default=`grep -n '^\[DEFAULT\]' /etc/nova/nova.conf | head -1 | cut -d : -f 1`
sed -i "${ln_default}a\\
network_api_class = nova.network.neutronv2.api.API\\
security_group_api = neutron\\
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver\\
firewall_driver = nova.virt.firewall.NoopFirewallDriver" /etc/nova/nova.conf
echo "[neutron]" >> /etc/nova/nova.conf
echo "url = http://${CTL_HOST}:9696" >> /etc/nova/nova.conf
echo "auth_strategy = keystone" >> /etc/nova/nova.conf
echo "admin_auth_url = http://${CTL_HOST}:35357/v2.0" >> /etc/nova/nova.conf
echo "admin_tenant_name = service" >> /etc/nova/nova.conf
echo "admin_username = neutron" >> /etc/nova/nova.conf
echo "admin_password = ${NEUTRON_PASS}" >> /etc/nova/nova.conf

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade juno" neutron

service nova-api restart
service nova-scheduler restart
service nova-conductor restart

service neutron-server restart

 
