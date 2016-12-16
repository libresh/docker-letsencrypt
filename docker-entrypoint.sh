#!/bin/bash -eux

HAPROXY_PATH=/etc/haproxy
CERTS_PATH=/var/certs
IP=`curl http://icanhazip.com/`
trap exit SIGHUP SIGINT SIGTERM

function issue_cert () {
  if [ "$(ping -c1 -n $1 | head -n1 | sed 's/.*(\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)).*/\1/g')" == "$IP" ]; then
    acme.sh \
      --home /usr/bin \
      --issue \
      -d $1 \
      -w /html-root \
      --reloadcmd "cat $CERTS_PATH/$1/$1.cer $CERTS_PATH/$1/ca.cer $CERTS_PATH/$1/$1.key > $HAPROXY_PATH/certs/$1.pem"
  fi
}

cd $HAPROXY_PATH

while true; do
  certs="$(ls -1 ${HAPROXY_PATH}/certs | sed -e 's/\.pem//')"
  domains="$(cat ${HAPROXY_PATH}/haproxy.cfg | grep backend | cut -f2 -d' ' | grep -v letsencrypt)"
  letsencrypt="$(comm -13 <(echo "${certs}" | sort) <(echo "${domains}" | sort))"

  for domain in `echo "${letsencrypt}"`; do
    issue_cert $domain
  done
  acme.sh --cron --home $CERTS_PATH
  inotifywait .
done
