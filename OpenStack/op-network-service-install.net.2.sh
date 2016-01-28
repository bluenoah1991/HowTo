#!/bin/bash

METADATA_SECRET=123456 # from op-network-service-install.net.sh

echo "service_metadata_proxy = True" >> /etc/nova/nova.conf # just once
echo "metadata_proxy_shared_secret = ${METADATA_SECRET}" >> /etc/nova/nova.conf # just once

service nova-api restart # run command line when adding compute nodes

