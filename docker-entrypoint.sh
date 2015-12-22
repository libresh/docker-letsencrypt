#!/bin/bash -eux

HAPROXY_PATH=/etc/haproxy
CERTS_PATH=/etc/letsencrypt/archive
IP=`wget -qO- http://icanhazip.com/`
cd $HAPROXY_PATH
trap exit SIGHUP SIGINT SIGTERM

while true; do
  certs="$(ls -1 ${HAPROXY_PATH}/certs | sed -e 's/\.pem//')"
  domains="$(cat ${HAPROXY_PATH}/haproxy.cfg | grep backend | cut -f2 -d' ' | grep -v letsencrypt)"
  letsencrypt="$(diff <(echo "${certs}" | sort) <(echo "${domains}" | sort) | grep '>' | cut -d' ' -f2)"

  for domain in `echo "${letsencrypt}"`; do
    if [ "$(host $domain | awk '/has address/ { print $4 ; exit }')" == "$IP" ]; then
      letsencrypt certonly -d $domain

      if [ -d $CERTS_PATH/$domain ]; then
        cat $CERTS_PATH/$domain/fullchain1.pem $CERTS_PATH/$domain/privkey1.pem > $HAPROXY_PATH/certs/$domain.pem
      fi
    fi
    if [ "$(host www.$domain | awk '/has address/ { print $4 ; exit }')" == "$IP" ]; then
      letsencrypt certonly -d www.$domain
      if [ -d $CERTS_PATH/www.$domain ]; then
        cat $CERTS_PATH/www.$domain/fullchain1.pem $CERTS_PATH/www.$domain/privkey1.pem > $HAPROXY_PATH/certs/www.$domain.pem
      fi
    fi
  done
  inotifywait .
done
