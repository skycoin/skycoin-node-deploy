#!/bin/bash

#<UDF name="hostname" label="The host name for the new Linode.">
# HOSTNAME=
#
#<UDF name="fqdn" label="The new Linode's Full Qualified Domain Name, bind the server ip to it once the server is up.">
# FQDN=
#
#<UDF name="email" label="The email address for receiving messages from letsEncrypt">
# EMAIL=
#

IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')

echo $HOSTNAME > /etc/hostname
hostname -F /etc/hostname

echo $IPADDR $FQDN $HOSTNAME >> /etc/hosts

apt-get update
apt-get upgrade -y

# install certbot
apt-get install dirmngr
apt-get install software-properties-common -y
add-apt-repository ppa:certbot/certbot -y
apt-get update
apt-get install python-certbot-nginx -y

# install nginx
apt-get install nginx -y
systemctl enable nginx
cat << EOF>/etc/nginx/conf.d/$FQDN.conf
server {
  listen          80;
  server_name $FQDN;

  location / {
    proxy_pass http://localhost:6420;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
EOF

# enable https with letsEncrypt
certbot certonly --nginx --agree-tos -n -d $FQDN --email $EMAIL

# Update nginx config to enable https
cat << EOF>/etc/nginx/conf.d/$FQDN.conf
server {

    server_name $FQDN;

    location / {
        proxy_pass http://localhost:6420;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/$FQDN/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/$FQDN/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
  listen          80;
  server_name     $FQDN;
  return          301 https://\$server_name\$request_uri;
}
EOF

# restart nginx service
systemctl restart nginx

mkdir -p /tmp/skycoin
cd /tmp/skycoin

# download skycoin executable file of v0.26
VERSION=0.26.0
wget "https://downloads.skycoin.net/wallet/skycoin-$VERSION-daemon-linux-x64.tar.gz"
tar -zxvf skycoin-$VERSION-daemon-linux-x64.tar.gz
cp skycoin-$VERSION-daemon-linux-x64/skycoin /usr/local/bin

# create skycoind service
cat <<EOF >/usr/bin/start_skycoin.sh
#!/bin/bash

/usr/local/bin/skycoin -disable-csrf=true -enable-api-sets="READ,TXN" -web-interface-addr="0.0.0.0" -web-interface-port="6420"
EOF
chmod +x /usr/bin/start_skycoin.sh

cat<<EOF >/etc/systemd/system/skycoind.service
[Unit]
Description=Skycoin node
After=network-online.target

[Service]
ExecStart=/usr/bin/start_skycoin.sh
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable skycoind.service
systemctl start skycoind.service
