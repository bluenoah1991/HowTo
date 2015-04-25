#!/bin/bash

CTL_HOST=controller
NEUTRON_PASS=123456
INSTANCE_TUNNELS_INTERFACE_IP_ADDRESS=10.0.1.31
RABBIT_PASS=123456 # from rabbit mq

sed -i "/^#net.ipv4.conf.default.rp_filter=1/cnet.ipv4.conf.default.rp_filter=0" /etc/sysctl.conf
sed -i "/^#net.ipv4.conf.all.rp_filter=1/cnet.ipv4.conf.all.rp_filter=0" /etc/sysctl.conf

sysctl -p

apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent -y

sed -i "/^connection/s/^/#/" /etc/neutron/neutron.conf
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
sed -i "/^# service_plugins =/cservice_plugins = router" /etc/neutron/neutron.conf
sed -i "/^# allow_overlapping_ips/callow_overlapping_ips = True" /etc/neutron/neutron.conf
sed -i "/^# verbose = False/cverbose = True" /etc/neutron/neutron.conf
sed -i "/^# type_drivers/ctype_drivers = flat,gre" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# tenant_network_types/ctenant_network_types = gre" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# mechanism_drivers/cmechanism_drivers = openvswitch" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# tunnel_id_ranges/ctunnel_id_ranges = 1:1000" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# enable_security_group/s/# //" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# enable_ipset/s/# //" /etc/neutron/plugins/ml2/ml2_conf.ini
echo "firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo "[ovs]" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo "local_ip = ${INSTANCE_TUNNELS_INTERFACE_IP_ADDRESS}" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo "enable_tunneling = True" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo "[agent]" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo "tunnel_types = gre" >> /etc/neutron/plugins/ml2/ml2_conf.ini

service openvswitch-switch restart

echo "network_api_class = nova.network.neutronv2.api.API" >> /etc/nova/nova.conf
echo "security_group_api = neutron" >> /etc/nova/nova.conf
echo "linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver" >> /etc/nova/nova.conf
echo "firewall_driver = nova.virt.firewall.NoopFirewallDriver" >> /etc/nova/nova.conf
echo "[neutron]" >> /etc/nova/nova.conf
echo "url = http://${CTL_HOST}:9696" >> /etc/nova/nova.conf
echo "auth_strategy = keystone" >> /etc/nova/nova.conf
echo "admin_auth_url = http://${CTL_HOST}:35357/v2.0" >> /etc/nova/nova.conf
echo "admin_tenant_name = service" >> /etc/nova/nova.conf
echo "admin_username = neutron" >> /etc/nova/nova.conf
echo "admin_password = ${NEUTRON_PASS}" >> /etc/nova/nova.conf

service nova-compute restart
service neutron-plugin-openvswitch-agent restart

