#!/bin/bash

set -e

# ====== COLORS ======
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ====== BANNER ======
clear
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║     WhatsApp Gateway Installer           ║"
echo "║     go-whatsapp-web-multidevice           ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ====== AUTH CHOICE ======
echo -e "${BOLD}Do you want to enable Basic Authentication?${NC}"
echo ""
echo -e "  ${GREEN}1)${NC} Yes — protect with username & password"
echo -e "  ${YELLOW}2)${NC} No  — open access (no auth)"
echo ""
read -rp "Choose [1/2]: " AUTH_CHOICE

USE_AUTH=false
WA_AUTH_USER=""
WA_AUTH_PASS=""
WA_PORT="3000"

if [[ "$AUTH_CHOICE" == "1" ]]; then
    USE_AUTH=true
    echo ""
    read -rp "Username : " WA_AUTH_USER
    read -rsp "Password : " WA_AUTH_PASS
    echo ""

    if [[ -z "$WA_AUTH_USER" || -z "$WA_AUTH_PASS" ]]; then
        echo -e "${RED}Error: Username and password cannot be empty.${NC}"
        exit 1
    fi
fi

# ====== PORT CHOICE ======
echo ""
read -rp "Port [default: 3000]: " INPUT_PORT
WA_PORT="${INPUT_PORT:-3000}"

# ====== CONFIRM ======
echo ""
echo -e "${CYAN}─────────────────────────────────────${NC}"
echo -e "  Auth    : $(if $USE_AUTH; then echo -e "${GREEN}Enabled${NC} ($WA_AUTH_USER)"; else echo -e "${YELLOW}Disabled${NC}"; fi)"
echo -e "  Port    : ${BOLD}$WA_PORT${NC}"
echo -e "${CYAN}─────────────────────────────────────${NC}"
echo ""
read -rp "Proceed with installation? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation cancelled.${NC}"
    exit 0
fi

# ====== UPDATE SYSTEM ======
echo ""
echo -e "${GREEN}[1/7]${NC} Updating system..."
apt update && apt upgrade -y

# ====== INSTALL DEPENDENCIES ======
echo -e "${GREEN}[2/7]${NC} Installing dependencies..."
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

# ====== INSTALL GO ======
echo -e "${GREEN}[3/7]${NC} Installing Go 1.25..."
rm -rf /usr/local/go || true
apt remove golang-go -y 2>/dev/null || true

cd /tmp
wget -q https://go.dev/dl/go1.25.0.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz
rm -f go1.25.0.linux-amd64.tar.gz

grep -q '/usr/local/go/bin' ~/.profile 2>/dev/null || echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
grep -q 'CGO_ENABLED=1' ~/.profile 2>/dev/null || echo 'export CGO_ENABLED=1' >> ~/.profile
export PATH=$PATH:/usr/local/go/bin
export CGO_ENABLED=1

echo -e "  Go version: $(/usr/local/go/bin/go version)"

# ====== CLONE & BUILD ======
echo -e "${GREEN}[4/7]${NC} Cloning repository..."
cd /root
rm -rf go-whatsapp-web-multidevice || true
git clone https://github.com/aldinokemal/go-whatsapp-web-multidevice
cd go-whatsapp-web-multidevice/src

echo -e "${GREEN}[5/7]${NC} Building application..."
go mod tidy
CGO_ENABLED=1 go build -o whatsapp

# ====== BUILD EXEC COMMAND ======
EXEC_CMD="/root/go-whatsapp-web-multidevice/src/whatsapp rest --port ${WA_PORT}"

if $USE_AUTH; then
    EXEC_CMD="${EXEC_CMD} --basic-auth=${WA_AUTH_USER}:${WA_AUTH_PASS}"
fi

# ====== CREATE SYSTEMD SERVICE ======
echo -e "${GREEN}[6/7]${NC} Creating systemd service..."

cat <<EOF > /etc/systemd/system/wagateway.service
[Unit]
Description=WhatsApp Gateway
After=network.target

[Service]
User=root
WorkingDirectory=/root/go-whatsapp-web-multidevice/src
ExecStart=${EXEC_CMD}
Restart=always
RestartSec=5
Environment=CGO_ENABLED=1

[Install]
WantedBy=multi-user.target
EOF

# ====== START SERVICE ======
echo -e "${GREEN}[7/7]${NC} Starting service..."
systemctl daemon-reload
systemctl enable wagateway
systemctl start wagateway

sleep 2
systemctl status wagateway --no-pager || true

# ====== DONE ======
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗"
echo -e "║        INSTALLATION COMPLETE ✓            ║"
echo -e "╠══════════════════════════════════════════╣"
echo -e "║  Access : http://YOUR_IP:${WA_PORT}$(printf '%*s' $((16 - ${#WA_PORT})) '')║"
if $USE_AUTH; then
echo -e "║  User   : ${WA_AUTH_USER}$(printf '%*s' $((27 - ${#WA_AUTH_USER})) '')║"
echo -e "║  Pass   : ********$(printf '%*s' 19 '')║"
fi
echo -e "╚══════════════════════════════════════════╝${NC}"
echo ""
