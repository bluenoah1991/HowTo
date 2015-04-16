#!/bin/bash

mkdir ~/.ssh
cp id_rsa.pub ~/.ssh/authorized_keys
chmod 644 ~/.ssh/authorized_keys
sed -i '/^#PasswordAuthentication/cPasswordAuthentication no' /etc/ssh/sshd_config
sed -i '/^#AuthorizedKeysFile/s/#//' /etc/ssh/sshd_config
/etc/init.d/ssh restart

