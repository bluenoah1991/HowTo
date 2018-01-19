#!/bin/bash

# /var need 5-10GB of free space

# Disable SELinux
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Security-Enhanced_Linux/sect-Security-Enhanced_Linux-Enabling_and_Disabling_SELinux-Disabling_SELinux.html
# vim /etc/selinux/config
# SELINUX=disabled

IPADDR=192.168.100.254

yum update
yum -y install createrepo httpd mkisofs mod_wsgi mod_ssl python-cheetah python-netaddr python-simplejson python-urlgrabber PyYAML rsync syslinux tftp-server yum-utils
yum -y install wget git make python-devel python-setuptools python-cheetah openssl

wget http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-6/home:libertas-ict:cobbler26.repo
cp home:libertas-ict:cobbler26.repo /etc/yum.repos.d/
yum update

yum -y install cobbler

sed -i "/^default_password_crypted/cdefault_password_crypted: \"$(openssl passwd -1)\"" /etc/cobbler/settings
sed -i "/^server:/cserver: ${IPADDR}" /etc/cobbler/settings
sed -i "/^next_server:/cnext_server: ${IPADDR}" /etc/cobbler/settings
sed -i "/^manage_dhcp:/cmanage_dhcp: 1" /etc/cobbler/settings

# vim /etc/cobbler/dhcp.template

#service cobblerd start
#chkconfig cobblerd on
#service cobblerd status
#service httpd stop
#service httpd start
#service cobblerd restart
#cobbler check

#yum install dhcp

#cp /usr/share/doc/dhcp-4.1.1/dhcpd.conf.sample /etc/dhcp/dhcpd.conf
#vim /etc/dhcp/dhcpd.conf  <---- http://geekpeek.net/how-to-install-dhcp-server-centos/
#service dhcpd start
#vim /etc/xinetd.d/tftp  <----
#vim /etc/xinetd.d/rsync  <----

#rpm -Uvi http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

#yum install debmirror pykickstart cman

#comment out 'dists' on /etc/debmirror.conf for proper debian support
#comment out 'arches' on /etc/debmirror.conf for proper debian support

#service cobblerd restart
#cobbler sync

#service iptables stop
#service xinetd stop
#service xinetd start

