#!/bin/bash

CTL_HOST=controller
NEUTRON_PASS=123456
INSTANCE_TUNNELS_INTERFACE_IP_ADDRESS=10.0.1.21
METADATA_SECRET=123456

sed -i "/^#net.ipv4.ip_forward=1/s/#//" /etc/sysctl.conf
sed -i "/^#net.ipv4.conf.default.rp_filter=1/cnet.ipv4.conf.default.rp_filter=0" /etc/sysctl.conf
sed -i "/^#net.ipv4.conf.all.rp_filter=1/cnet.ipv4.conf.all.rp_filter=0" /etc/sysctl.conf

sysctl -p

apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent \
  neutron-l3-agent neutron-dhcp-agent -y

sed -i "/^#rpc_backend=rabbit/s/#//" /etc/neutron/neutron.conf
sed -i "/^#rabbit_host=localhost/crabbit_host = ${CTL_HOST}" /etc/neutron/neutron.conf
sed -i "/^#rabbit_password=guest/crabbit_password = ${RABBIT_PASS}" /etc/neutron/neutron.conf
sed -i "/^# auth_strategy/s/#//" /etc/neutron/neutron.conf
ln_keystone_authtoken=`grep -n '^\[keystone_authtoken\]' /etc/neutron/neutron.conf | head -1 | cut -d : -f 1`
sed -i "${ln_keystone_authtoken}a\\
auth_uri = http://${CTL_HOST}:5000/v2.0\\
identity_uri = http://${CTL_HOST}:35357" /etc/neutron/neutron.conf
sed -i "/^admin_tenant_name/cadmin_tenant_name = service" /etc/neutron/neutron.conf
sed -i "/^admin_user/cadmin_user = neutron" /etc/neutron/neutron.conf
sed -i "/^admin_password/cadmin_password = ${NEUTRON_PASS}" /etc/neutron/neutron.conf
sed -i "/^# service_plugins/cservice_plugins = router" /etc/neutron/neutron.conf
sed -i "/^# allow_overlapping_ips/callow_overlapping_ips = True" /etc/neutron/neutron.conf
sed -i "/^# verbose = False/cverbose = True" /etc/neutron/neutron.conf

sed -i "/^# type_drivers/ctype_drivers = flat,gre" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# tenant_network_types/ctenant_network_types = gre" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# mechanism_drivers/cmechanism_drivers = openvswitch" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# flat_networks =/cflat_networks = external" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# tunnel_id_ranges/ctunnel_id_ranges = 1:1000" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# enable_security_group/s/# //" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# enable_ipset/s/# //" /etc/neutron/plugins/ml2/ml2_conf.ini
echo "firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo "[ovs]" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo "local_ip = ${INSTANCE_TUNNELS_INTERFACE_IP_ADDRESS}" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo "enable_tunneling = True" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo "bridge_mappings = external:br-ex" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo "[agent]" >> /etc/neutron/plugins/ml2/ml2_conf.ini
echo "tunnel_types = gre" >> /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^# interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver/s/#//" /etc/neutron/l3_agent.ini
sed -i "/^# use_namespaces = True/s/#//" /etc/neutron/l3_agent.ini
ln_default=`grep -n '^\[DEFAULT\]' /etc/neutron/l3_agent.ini | head -1 | cut -d : -f 1`
sed -i "${ln_default}a\\
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq\\
dhcp_delete_namespaces = True\\
verbose = True" /etc/neutron/dhcp_agent.ini

# 2 (Optional)

sed -i "/^auth_url/cauth_url = http://${CTL_HOST}:5000/v2.0" /etc/neutron/metadata_agent.ini
sed -i "/^admin_tenant_name/cadmin_tenant_name = service" /etc/neutron/metadata_agent.ini
sed -i "/^admin_user/cadmin_user = neutron" /etc/neutron/metadata_agent.ini
sed -i "/^admin_password/cadmin_password = ${NEUTRON_PASS}" /etc/neutron/metadata_agent.ini
sed -i "/^# nova_metadata_ip = 127.0.0.1/cnova_metadata_ip = ${CTL_HOST}" /etc/neutron/metadata_agent.ini
sed -i "/^# metadata_proxy_shared_secret =/cmetadata_proxy_shared_secret = ${METADATA_SECRET}" /etc/neutron/metadata_agent.ini
ln_default=`grep -n '^\[DEFAULT\]' /etc/neutron/metadata_agent.ini | head -1 | cut -d : -f 1`
sed -i "${ln_default}a\\
verbose = True" /etc/neutron/metadata_agent.ini


