#!/bin/bash

set -e

echo "===== UPDATE SYSTEM ====="
apt update && apt upgrade -y

echo "===== INSTALL DEPENDENCIES ====="
apt install -y \
build-essential \
gcc \
g++ \
make \
pkg-config \
git \
curl \
wget \
sqlite3 \
libsqlite3-dev \
libc6-dev \
ffmpeg \
webp \
ca-certificates

echo "===== REMOVE OLD GO IF EXISTS ====="
rm -rf /usr/local/go || true
apt remove golang-go -y || true

echo "===== INSTALL GO 1.25 ====="
cd /tmp
wget -q https://go.dev/dl/go1.25.0.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz

echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
echo "export CGO_ENABLED=1" >> ~/.profile
source ~/.profile

echo "===== VERIFY GO VERSION ====="
go version

echo "===== CLONE REPOSITORY ====="
cd /root
rm -rf go-whatsapp-web-multidevice || true
git clone https://github.com/aldinokemal/go-whatsapp-web-multidevice
cd go-whatsapp-web-multidevice/src

echo "===== DOWNLOAD GO MODULES ====="
go mod tidy

echo "===== BUILD APPLICATION ====="
CGO_ENABLED=1 go build -o whatsapp

echo "===== CREATE SYSTEMD SERVICE ====="

cat <<EOF > /etc/systemd/system/wagateway.service
[Unit]
Description=WhatsApp Gateway
After=network.target

[Service]
User=root
WorkingDirectory=/root/go-whatsapp-web-multidevice/src
ExecStart=/root/go-whatsapp-web-multidevice/src/whatsapp rest
Restart=always
Environment=CGO_ENABLED=1

[Install]
WantedBy=multi-user.target
EOF

echo "===== ENABLE SERVICE ====="
systemctl daemon-reload
systemctl enable wagateway
systemctl start wagateway

echo "===== STATUS ====="
systemctl status wagateway --no-pager

echo "======================================="
echo "INSTALLATION COMPLETE"
echo "Access: http://IP_SERVER:3000"
echo "======================================="
