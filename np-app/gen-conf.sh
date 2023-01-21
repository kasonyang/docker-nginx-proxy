#!/usr/bin/env bash


execSSLInstall() {
  for file in *.toml
  do
    domain="${file%.toml}"
    certFile="/root/.acme.sh/$domain/fullchain.cer"
    sslKeyFile="/var/nginx-proxy/certs/$domain/key.pem"
    fullchainFile="/var/nginx-proxy/certs/$domain/fullchain.pem"
    if [ ! -f "$certFile" ]
    then
      /root/.acme.sh/acme.sh --issue -d "$domain" -w /usr/share/nginx/html/
    fi
    mkdir -p /var/nginx-proxy/certs/"$domain"
    /root/.acme.sh/acme.sh --install-cert -d "$domain" --key-file "$sslKeyFile" --fullchain-file "$fullchainFile" --reloadcmd "nginx -s reload"
  done
}

generateNginxConf() {
  rm -rf /etc/nginx/conf.d/*
  for file in *.toml
  do
    domain="${file%.toml}"
    if [ "$AUTO_SSL" = "on" ]; then
      # generating cert
      fullchainFile="/var/nginx-proxy/certs/$domain/fullchain.pem"
      keyFile="/var/nginx-proxy/certs/$domain/key.pem"
    else
      # user cert
      fullchainFile="/etc/nignx-proxy/certs/$domain/fullchain.pem"
      keyFile="/etc/nignx-proxy/certs/$domain/key.pem"
    fi
    if [ ! -f "$fullchainFile" ] || [ ! -f "$keyFile" ]; then
      fullchainFile=""
      keyFile=""
    fi
    confFile="/etc/nginx/conf.d/$domain.conf"
    /np-app/tpl-gen -d "$file" -o "$confFile" -v:ssl_key "$keyFile" -v:ssl_cert "$fullchainFile" -v:domain "$domain" /np-app/host.conf.tpl
  done
}

echo "Generating nginx conf..."
generateNginxConf
echo "Reloading nginx..."
nginx -s reload
if [ "$AUTO_SSL" = "on" ]; then
  echo "Installing ssl..."
  execSSLInstall
  echo "Regenerating nginx conf..."
  generateNginxConf
  echo "Reloading nginx..."
  nginx -s reload
fi
