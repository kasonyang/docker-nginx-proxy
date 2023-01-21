#!/usr/bin/env bash

copyAcmeApp() {
  if [ -L "/root/.acme.sh" ]; then
    echo "acmeApp is copied already"
    return
  fi
  mkdir -p /var/nginx-proxy/acme.sh
  cp -r /root/.acme.sh/* /var/nginx-proxy/acme.sh
  rm -rf /root/.acme.sh
  ln -sfn /var/nginx-proxy/acme.sh /root/.acme.sh
  echo "copyAcmeApp finished"
}

loopAcmeCron() {
  while :
  do
    /root/.acme.sh/acme.sh --cron --home "/root/.acme.sh"
    sleep 86400
  done
}

nginx
cd /etc/nginx-proxy/vhosts || exit
if [ "$AUTO_SSL" = "on" ]; then
  copyAcmeApp
  if [ -z "$AUTO_SSL_EMAIL" ]; then
    echo "Missing EMAIL environment variable"
    exit 1;
  fi
  /root/.acme.sh/acme.sh --register-account -m "$AUTO_SSL_EMAIL"
fi
/np-app/run-on-change -i "*.toml" sh /np-app/gen-conf.sh &

if [ "$AUTO_SSL" = "on" ]; then
  loopAcmeCron
else
  tail -f /dev/null
fi