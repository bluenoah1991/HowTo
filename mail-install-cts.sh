#!/bin/bash

DOMAIN=example.com
HOSTNAME=mail.example.com
MAILDIR=/vmail
DBNAME=mail
DBUSER=mail_admin
DBPWD=123456

yum -y update
yum -y --enablerepo=centosplus install postfix 
yum -y install dovecot mysql-server 
chkconfig mysqld on
service mysqld start
mysql_secure_installation

echo 'Please enter your Mysql(root) password:'
read MYSQLPWD
mysql -uroot -p${MYSQLPWD} << EOF
CREATE DATABASE ${DBNAME};
USE ${DBNAME};
GRANT SELECT, INSERT, UPDATE, DELETE ON ${DBNAME}.* TO '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPWD}';
GRANT SELECT, INSERT, UPDATE, DELETE ON ${DBNAME}.* TO '${DBUSER}'@'localhost.localdomain' IDENTIFIED BY '${DBPWD}';
FLUSH PRIVILEGES;
CREATE TABLE domains (domain varchar(50) NOT NULL, PRIMARY KEY (domain) );
CREATE TABLE forwardings (source varchar(80) NOT NULL, destination TEXT NOT NULL, PRIMARY KEY (source) );
CREATE TABLE users (email varchar(80) NOT NULL, password varchar(255) NOT NULL, PRIMARY KEY (email) );
CREATE TABLE transport ( domain varchar(128) NOT NULL default '', transport varchar(128) NOT NULL default '', UNIQUE KEY domain (domain) );
EOF

cp /etc/my.cnf /etc/my.cnf.backup
echo "bind-address=127.0.0.1" >> /etc/my.cnf

service mysqld restart

echo -e "
user = ${DBUSER}
password = ${DBPWD}
dbname = ${DBNAME}
query = SELECT domain AS virtual FROM domains WHERE domain='%s'
hosts = 127.0.0.1
" > /etc/postfix/mysql-virtual_domains.cf

echo -e "
user = ${DBUSER}
password = ${DBPWD}
dbname = ${DBNAME}
query = SELECT destination FROM forwardings WHERE source='%s'
hosts = 127.0.0.1
" > /etc/postfix/mysql-virtual_forwardings.cf

echo -e "
user = ${DBUSER}
password = ${DBPWD}
dbname = ${DBNAME}
query = SELECT CONCAT(SUBSTRING_INDEX(email,<'@'>,-1),'/',SUBSTRING_INDEX(email,<'@'>,1),'/') FROM users WHERE email='%s'
hosts = 127.0.0.1
" > /etc/postfix/mysql-virtual_mailboxes.cf

echo -e "
user = ${DBUSER}
password = ${DBPWD}
dbname = ${DBNAME}
query = SELECT email FROM users WHERE email='%s'
hosts = 127.0.0.1
" > /etc/postfix/mysql-virtual_email2email.cf

chmod o= /etc/postfix/mysql-virtual_*.cf
chgrp postfix /etc/postfix/mysql-virtual_*.cf
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /home/vmail -m

# Postfix Configuration

postconf -e "myhostname = ${HOSTNAME}"
postconf -e 'mydestination = $myhostname, localhost, localhost.localdomain'
postconf -e 'mynetworks = 127.0.0.0/8'
postconf -e 'inet_interfaces = all'
postconf -e 'message_size_limit = 30720000'
postconf -e 'virtual_alias_domains ='
postconf -e 'virtual_alias_maps = proxy:mysql:/etc/postfix/mysql-virtual_forwardings.cf, mysql:/etc/postfix/mysql-virtual_email2email.cf'
postconf -e 'virtual_mailbox_domains = proxy:mysql:/etc/postfix/mysql-virtual_domains.cf'
postconf -e 'virtual_mailbox_maps = proxy:mysql:/etc/postfix/mysql-virtual_mailboxes.cf'
postconf -e "virtual_mailbox_base = ${MAILDIR}"
postconf -e 'virtual_uid_maps = static:5000'
postconf -e 'virtual_gid_maps = static:5000'
postconf -e 'smtpd_sasl_type = dovecot'
postconf -e 'smtpd_sasl_path = private/auth'
postconf -e 'smtpd_sasl_auth_enable = yes'
postconf -e 'broken_sasl_auth_clients = yes'
postconf -e 'smtpd_sasl_authenticated_header = yes'
postconf -e 'smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination'
postconf -e 'smtpd_use_tls = yes'
postconf -e 'smtpd_tls_cert_file = /etc/pki/dovecot/certs/dovecot.pem'
postconf -e 'smtpd_tls_key_file = /etc/pki/dovecot/private/dovecot.pem'
postconf -e 'virtual_create_maildirsize = yes'
postconf -e 'virtual_maildir_extended = yes'
postconf -e 'proxy_read_maps = $local_recipient_maps $mydestination $virtual_alias_maps $virtual_alias_domains $virtual_mailbox_maps $virtual_mailbox_domains $relay_recipient_maps $relay_domains $canonical_maps $sender_canonical_maps $recipient_canonical_maps $relocated_maps $transport_maps $mynetworks $virtual_mailbox_limit_maps'
postconf -e 'virtual_transport = dovecot'
postconf -e 'dovecot_destination_recipient_limit = 1'

# End

echo -e "
dovecot   unix  -       n       n       -       -       pipe
    flags=DRhu user=vmail:vmail argv=/usr/libexec/dovecot/deliver -f ${sender} -d ${recipient}
" >> /etc/postfix/master.cf

service sendmail stop
chkconfig sendmail off
chkconfig postfix on
service postfix start

mv /etc/dovecot.conf /etc/dovecot.conf.backup

echo -e "
protocols = imap imaps pop3 pop3s
log_timestamp = "%Y-%m-%d %H:%M:%S "
mail_location = maildir:${MAILDIR}/%d/%n/Maildir

ssl_cert_file = /etc/pki/dovecot/certs/dovecot.pem
ssl_key_file = /etc/pki/dovecot/private/dovecot.pem

namespace private {
    separator = .
    prefix = INBOX.
    inbox = yes
}
    
protocol lda {
    log_path = /home/vmail/dovecot-deliver.log
    auth_socket_path = /var/run/dovecot/auth-master
    postmaster_address = postmaster@${DOMAIN}
}

protocol pop3 {
pop3_uidl_format = %08Xu%08Xv
}

auth default {
    user = root

    passdb sql {
        args = /etc/dovecot-sql.conf
    }

    userdb static {
        args = uid=5000 gid=5000 home=/home/vmail/%d/%n allow_all_users=yes
    }

    socket listen {
        master {
            path = /var/run/dovecot/auth-master
            mode = 0600
            user = vmail
        }

        client {
            path = /var/spool/postfix/private/auth
            mode = 0660
            user = postfix
            group = postfix
        }
    
    }

}
" > /etc/dovecot.conf

echo -e "
driver = mysql
connect = host=127.0.0.1 dbname=${DBNAME} user=${DBUSER} password=${DBPWD}
default_pass_scheme = MD5-CRYPT
password_query = SELECT email as user, password FROM users WHERE email='%u';
" > /etc/dovecot-sql.conf

chgrp dovecot /etc/dovecot-sql.conf
chmod o= /etc/dovecot-sql.conf

chkconfig dovecot on
service dovecot start

echo "root: postmaster@${DOMAIN}" >> /etc/aliases

newaliases
service postfix restart


mysql -uroot -p${MYSQLPWD} << EOF
USE mail;
INSERT INTO domains (domain) VALUES ('${DOMAIN}');
INSERT INTO users (email, password) VALUES ('mail1@${DOMAIN}', ENCRYPT('123456',concat('\$1\$',substring(rand(),3,8),'$')));
INSERT INTO users (email, password) VALUES ('mail2@${DOMAIN}', ENCRYPT('123456',concat('\$1\$',substring(rand(),3,8),'$')));
EOF

echo "Success!"

