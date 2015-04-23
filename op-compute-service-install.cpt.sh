#!/bin/bash

CTL_HOST=controller
RABBIT_PASS=123456 # from rabbit mq
NOVA_PASS=123456 # from op-compute-service-install.ctr.sh
MANAGEMENT_INTERFACE_IP_ADDRESS=10.0.0.31

apt-get install nova-compute sysfsutils -y

echo "#rpc_backend = rabbit" >> /etc/nova/nova.conf
echo "rabbit_host = ${CTL_HOST}" >> /etc/nova/nova.conf
echo "rabbit_password = ${RABBIT_PASS}" >> /etc/nova/nova.conf
echo "auth_strategy = keystone" >> /etc/nova/nova.conf
echo "my_ip = ${MANAGEMENT_INTERFACE_IP_ADDRESS}" >> /etc/nova/nova.conf
echo "vnc_enabled = True" >> /etc/nova/nova.conf
echo "vncserver_listen = 0.0.0.0" >> /etc/nova/nova.conf
echo "vncserver_proxyclient_address = ${MANAGEMENT_INTERFACE_IP_ADDRESS}" >> /etc/nova/nova.conf
echo "novncproxy_base_url = http://${CTL_HOST}:6080/vnc_auto.html" >> /etc/nova/nova.conf

echo "[keystone_authtoken]" >> /etc/nova/nova.conf
echo "auth_uri = http://${CTL_HOST}:5000/v2.0" >> /etc/nova/nova.conf
echo "identity_uri = http://${CTL_HOST}:35357" >> /etc/nova/nova.conf
echo "admin_tenant_name = service" >> /etc/nova/nova.conf
echo "admin_user = nova" >> /etc/nova/nova.conf
echo "admin_password = ${NOVA_PASS}" >> /etc/nova/nova.conf

echo "[glance]" >> /etc/nova/nova.conf
echo "host = ${CTL_HOST}" >> /etc/nova/nova.conf

if [ `egrep -c '(vmx|svm)' /proc/cpuinfo` -eq 0 ]; then
  sed -i "/^virt_type=kvm/cvirt_type=qemu" /etc/nova/nova-compute.conf
fi

service nova-compute restart

rm -f /var/lib/nova/nova.sqlite
