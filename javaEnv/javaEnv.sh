#!/bin/bash

JDK_TAR_FILE=jdk-8u73-linux-x64.tar.gz

tar zxvf ./${JDK_TAR_FILE} -C /usr/local
cp /etc/sysctl.conf /etc/sysctl.conf.backup
echo -e "
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

JAVA_DIR=`ls -l /usr/local | grep jdk[^-] | rev | cut -d ' ' -f1 | rev`
ln -s /usr/local/${JAVA_DIR} /usr/local/jdk

cp /etc/profile /etc/profile.backup
echo -e "
export JAVA_HOME=/usr/local/jdk
export CLASSPATH=\$JAVA_HOME/lib
export PATH=\$PATH:\$JAVA_HOME/bin
" >> /etc/profile

# export JAVA_HOME=/usr/local/jdk
# export CLASSPATH=$JAVA_HOME/lib
# export PATH=$PATH:$JAVA_HOME/bin

# update-alternatives --config java
# update-alternatives --config javac
