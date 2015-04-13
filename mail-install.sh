#!/bin/bash

#Please run this script using root
#first configuration your host dns

DOMAIN=example.com
HOSTNAME=mail.example.com
DBNAME=mailserver
DBUSER=admin
DBPWD=123456
UPWD=123456
ADMINNAME=zhouyy
MAILDIR=/var/mail/vhosts/

hostname ${HOSTNAME}
echo ${HOSTNAME} > /etc/hostname

LINE=`grep -n 127.0.0.1 /etc/hosts | head -1 | cut -d : -f 1`
sed -i "${LINE}c 127.0.0.1\t${HOSTNAME} localhost" /etc/hosts
LINE=`grep -n 127.0.1.1 /etc/hosts | head -1 | cut -d : -f 1`
sed -i "${LINE}c 127.0.1.1\t${HOSTNAME}" /etc/hosts

apt-get install --assume-yes ssl-cert
make-ssl-cert generate-default-snakeoil --force-overwrite

apt-get install postfix postfix-mysql dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql mysql-server -y

#Enter your Mysql admin password
#password again
#Create a self-signed SSL certificate? ---> No
#General type of mail configuration ---> Internet Site
#System mail name ---> not change

echo 'Please tell me your Mysql password:'
read MYSQLPWD

mysqladmin -p${MYSQLPWD} create ${DBNAME}

sql1="GRANT SELECT ON ${DBNAME}.* TO '${DBUSER}'@'127.0.0.1' IDENTIFIED BY '${DBPWD}'"
sql2="
  INSERT INTO \`${DBNAME}\`.\`virtual_domains\`
    (\`id\` ,\`name\`)
  VALUES
    ('1', '${DOMAIN}'),
    ('2', '${HOSTNAME}'),
    ('3', 'localhost.${DOMAIN}')
"
sql3="
  INSERT INTO \`${DBNAME}\`.\`virtual_users\`
    (\`id\`, \`domain_id\`, \`password\` , \`email\`)
  VALUES
    ('1', '1', ENCRYPT('${UPWD}', CONCAT('\$6\$', SUBSTRING(SHA(RAND()), -16))), '${ADMINNAME}@${DOMAIN}'),
    ('2', '1', ENCRYPT('${UPWD}', CONCAT('\$6\$', SUBSTRING(SHA(RAND()), -16))), 'email1@${DOMAIN}'),
    ('3', '1', ENCRYPT('${UPWD}', CONCAT('\$6\$', SUBSTRING(SHA(RAND()), -16))), 'email2@${DOMAIN}')
"
sql4="
  INSERT INTO \`${DBNAME}\`.\`virtual_aliases\`
    (\`id\`, \`domain_id\`, \`source\`, \`destination\`)
  VALUES
    ('1', '1', 'admin@${DOMAIN}', '${ADMINNAME}@${DOMAIN}')
"


mysql -uroot -p${MYSQLPWD} ${DBNAME} << EOF
  
  ${sql1};
  
  FLUSH PRIVILEGES;
  
  CREATE TABLE \`virtual_domains\` (
    \`id\` int(11) NOT NULL auto_increment,
    \`name\` varchar(50) NOT NULL,
    PRIMARY KEY (\`id\`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  CREATE TABLE \`virtual_users\` (
    \`id\` int(11) NOT NULL auto_increment,
    \`domain_id\` int(11) NOT NULL,
    \`password\` varchar(106) NOT NULL,
    \`email\` varchar(100) NOT NULL,
    PRIMARY KEY (\`id\`),
    UNIQUE KEY \`email\` (\`email\`),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  CREATE TABLE \`virtual_aliases\` (
    \`id\` int(11) NOT NULL auto_increment,
    \`domain_id\` int(11) NOT NULL,
    \`source\` varchar(100) NOT NULL,
    \`destination\` varchar(100) NOT NULL,
    PRIMARY KEY (\`id\`),
    FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  ${sql2};
  ${sql3};
  ${sql4};
  
EOF

#Postfix

cp /etc/postfix/main.cf /etc/postfix/main.cf.orig
sed -i '/^smtpd_tls_session_cache_database/s/^/#/' /etc/postfix/main.cf
sed -i '/^smtp_tls_session_cache_database/s/^/#/' /etc/postfix/main.cf
sed -i '/^smtpd_use_tls=yes/asmtpd_tls_auth_only = yes' /etc/postfix/main.cf

echo -e "
#Enabling SMTP for authenticated users, and handing off authentication to Dovecot
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes

smtpd_recipient_restrictions =
\tpermit_sasl_authenticated,
\tpermit_mynetworks,
\treject_unauth_destination
" >> /etc/postfix/main.cf

sed -i '/^mydestination/cmydestination = localhost' /etc/postfix/main.cf

echo -e "
#Handing off local delivery to Dovecot's LMTP, and telling it where to store mail\n
virtual_transport = lmtp:unix:private/dovecot-lmtp\n
" >> /etc/postfix/main.cf

echo -e "
#Virtual domains, users, and aliases
virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf
" >> /etc/postfix/main.cf

echo -e "
user = ${DBUSER}
password = ${DBPWD}
hosts = 127.0.0.1
dbname = ${DBNAME}
query = SELECT 1 FROM virtual_domains WHERE name='%s'
" >> /etc/postfix/mysql-virtual-mailbox-domains.cf

echo -e "
user = ${DBUSER}
password = ${DBPWD}
hosts = 127.0.0.1
dbname = ${DBNAME}
query = SELECT 1 FROM virtual_users WHERE email='%s'
" >> /etc/postfix/mysql-virtual-mailbox-maps.cf

echo -e "
user = ${DBUSER}
password = ${DBPWD}
hosts = 127.0.0.1
dbname = ${DBNAME}
query = SELECT destination FROM virtual_aliases WHERE source='%s'
" >> /etc/postfix/mysql-virtual-alias-maps.cf

cp /etc/postfix/master.cf /etc/postfix/master.cf.orig
sed -i '/^#submission/s/#//' /etc/postfix/master.cf
sed -i '/^#smtps/s/#//' /etc/postfix/master.cf

service postfix restart

#Dovecot

cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.orig
cp /etc/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf.orig
cp /etc/dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf.orig
cp /etc/dovecot/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext.orig
cp /etc/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf.orig
cp /etc/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf.orig

sed -i '/^!include_try/aprotocols = imap pop3 lmtp' /etc/dovecot/dovecot.conf
sed -i "/^mail_location/cmail_location = maildir:${MAILDIR}%d/%n" /etc/dovecot/conf.d/10-mail.conf
sed -i '/^#mail_privileged_group/cmail_privileged_group = mail' /etc/dovecot/conf.d/10-mail.conf

mkdir -p ${MAILDIR}${DOMAIN}
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d ${MAILDIR}
chown -R vmail:vmail ${MAILDIR}

sed -i '/^#disable_plaintext_auth/s/#//' /etc/dovecot/conf.d/10-auth.conf
sed -i '/^auth_mechanisms/cauth_mechanisms = plain login' /etc/dovecot/conf.d/10-auth.conf
sed -i '/^!include auth-system.conf.ext/s/^/#/' /etc/dovecot/conf.d/10-auth.conf
sed -i '/^#!include auth-sql.conf.ext/s/#//' /etc/dovecot/conf.d/10-auth.conf

l1=`grep -n '^passdb {' /etc/dovecot/conf.d/auth-sql.conf.ext | head -1 | cut -d : -f 1`
sed -i "`expr ${l1} + 1`s/static/sql/" /etc/dovecot/conf.d/auth-sql.conf.ext
sed -i "`expr ${l1} + 4`cargs = \/etc\/dovecot\/dovecot-sql.conf.ext" /etc/dovecot/conf.d/auth-sql.conf.ext

l1=`grep -n '^userdb {' /etc/dovecot/conf.d/auth-sql.conf.ext | head -1 | cut -d : -f 1`
sed -i "`expr ${l1} + 1`s/sql/static/" /etc/dovecot/conf.d/auth-sql.conf.ext
sed -i "`expr ${l1} + 2`cargs = uid=vmail gid=vmail home=${MAILDIR}%d/%n" /etc/dovecot/conf.d/auth-sql.conf.ext

sed -i '/^#driver/cdriver = mysql' /etc/dovecot/dovecot-sql.conf.ext
sed -i "/^#connect/cconnect = host=127.0.0.1 dbname=${DBNAME} user=${DBUSER} password=${DBPWD}" /etc/dovecot/dovecot-sql.conf.ext
sed -i '/^#default_pass_scheme/cdefault_pass_scheme = SHA512-CRYPT' /etc/dovecot/dovecot-sql.conf.ext
l1=`grep -n '^#password_query' /etc/dovecot/dovecot-sql.conf.ext | head -1 | cut -d : -f 1`
sed -i "${l1}cpassword_query = SELECT email as user, password FROM virtual_users WHERE email='%u';" /etc/dovecot/dovecot-sql.conf.ext

chown -R vmail:dovecot /etc/dovecot
chmod -R o-rwx /etc/dovecot

l2=`grep -n 'unix_listener lmtp' /etc/dovecot/conf.d/10-master.conf | head -1 | cut -d : -f 1`
sed -i "${l2}s/lmtp/\/var\/spool\/postfix\/private\/dovecot-lmtp/" /etc/dovecot/conf.d/10-master.conf
sed -i "${l2}a\\
\\tmode = 0600\\
\\tuser = postfix\\
\\tgroup = postfix" /etc/dovecot/conf.d/10-master.conf
sed -i '/unix_listener auth-userdb {/iunix_listener \/var\/spool\/postfix\/private\/auth {\
\tmode = 0666\
\tuser = postfix\
\tgroup = postfix\
}' /etc/dovecot/conf.d/10-master.conf
sed -i '/unix_listener auth-userdb {/a\
\tmode = 0600\
\tuser = vmail' /etc/dovecot/conf.d/10-master.conf
sed -i '/#user = $default_internal_user/cuser = dovecot' /etc/dovecot/conf.d/10-master.conf
sed -i '/#user = root/cuser = vmail' /etc/dovecot/conf.d/10-master.conf

sed -i '/^ssl_cert/cssl_cert = </etc/ssl/certs/ssl-cert-snakeoil.pem' /etc/dovecot/conf.d/10-ssl.conf
sed -i '/^ssl_key/cssl_key = </etc/ssl/private/ssl-cert-snakeoil.key' /etc/dovecot/conf.d/10-ssl.conf
sed -i '/^#ssl = yes/s/#//' /etc/dovecot/conf.d/10-ssl.conf

service dovecot restart

echo 'success!'




