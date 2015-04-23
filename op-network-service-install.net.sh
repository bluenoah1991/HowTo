#!/bin/bash

sed -i "/^#net.ipv4.ip_forward=1/s/#//" /etc/sysctl.conf
sed -i "/^#net.ipv4.conf.default.rp_filter=1/cnet.ipv4.conf.default.rp_filter=0" /etc/sysctl.conf
sed -i "/^#net.ipv4.conf.all.rp_filter=1/cnet.ipv4.conf.all.rp_filter=0" /etc/sysctl.conf

sysctl -p

apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent \
  neutron-l3-agent neutron-dhcp-agent -y


