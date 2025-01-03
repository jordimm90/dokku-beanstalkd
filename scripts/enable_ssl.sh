#!/bin/sh

set -e

cd /var/lib/beanstalkdql/data

cp ../certs/* .
chown beanstalkd:beanstalkd server.key
chmod 600 server.key

sed -i "s/^#ssl = off/ssl = on/" beanstalkdql.conf
sed -i "s/^#ssl_ciphers =.*/ssl_ciphers = 'AES256+EECDH:AES256+EDH'/" beanstalkdql.conf
