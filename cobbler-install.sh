#!/bin/bash

#/var need 5-10GB of free space

yum update
yum -y install createrepo httpd mkisofs mod_wsgi mod_ssl python-cheetah python-netaddr python-simplejson python-urlgrabber PyYAML rsync syslinux tftp-server yum-utils
yum -y install wget git make python-devel python-setuptools python-cheetah openssl

wget http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-6/home:libertas-ict:cobbler26.repo
cp home:libertas-ict:cobbler26.repo /etc/yum.repos.d/
yum update

rpm -Uvi http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

yum -y install Django cobbler cobbler-web

sed -i "/^default_password_crypted/cdefault_password_crypted: \"$(openssl passwd -1)\"
