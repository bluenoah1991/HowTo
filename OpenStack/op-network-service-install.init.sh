#!/bin/bash

CTL_HOST=controller
ADMIN_PASS=123456 # from identity service

FLOATING_IP_START=10.0.0.100
FLOATING_IP_END=10.0.0.200
EXTERNAL_NETWORK_GATEWAY=10.0.0.1
EXTERNAL_NETWORK_CIDR=10.0.0.0/24 
TENANT_NETWORK_GATEWAY=10.0.1.1
TENANT_NETWORK_CIDR=10.0.1.0/24 

export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=${ADMIN_PASS}
export OS_AUTH_URL=http://${CTL_HOST}:35357/v2.0

neutron net-create ext-net --router:external True \
  --provider:physical_network external --provider:network_type flat

neutron subnet-create ext-net --name ext-subnet \
  --allocation-pool start=${FLOATING_IP_START},end=${FLOATING_IP_END} \
  --disable-dhcp --gateway ${EXTERNAL_NETWORK_GATEWAY} ${EXTERNAL_NETWORK_CIDR}
neutron net-create demo-net
neutron subnet-create demo-net --name demo-subnet \
  --gateway ${TENANT_NETWORK_GATEWAY} ${TENANT_NETWORK_CIDR}
neutron router-create demo-router
neutron router-interface-add demo-router demo-subnet
neutron router-gateway-set demo-router ext-net
