# WhatsApp Gateway Installer

Automated installer for [go-whatsapp-web-multidevice](https://github.com/aldinokemal/go-whatsapp-web-multidevice) on Ubuntu/Debian servers.

## Quick Start

```bash
wget -qO install.sh https://raw.githubusercontent.com/desienkz-slp/whatsapp/main/install.sh && bash install.sh
```

The installer will ask you:

1. **Enable auth?** — Choose yes/no
2. **Username & Password** — If auth is enabled
3. **Port** — Default `3000`

## What It Does

1. Updates system packages
2. Installs build dependencies (gcc, make, sqlite3, ffmpeg, etc.)
3. Installs **Go 1.25**
4. Clones & builds the WhatsApp gateway binary
5. Creates a `wagateway` systemd service
6. Starts the service automatically

## Requirements

- Ubuntu 22.04+ / Debian 12+
- Root access
- Minimum 1 GB RAM (for Go build)
