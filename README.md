# WhatsApp Gateway Installer

Automated installer scripts for [go-whatsapp-web-multidevice](https://github.com/aldinokemal/go-whatsapp-web-multidevice) on Ubuntu/Debian servers.

## Scripts

| Script | Description |
|---|---|
| `wa-gate.sh` | Full install with **Basic Auth** enabled |
| `wa-gate-noauth.sh` | Full install **without** authentication |

## What It Does

1. Updates system packages
2. Installs build dependencies (gcc, make, sqlite3, ffmpeg, etc.)
3. Installs **Go 1.25**
4. Clones & builds the WhatsApp gateway binary
5. Creates a `wagateway` systemd service
6. Starts the service on port `3000`

## Quick Start

```bash
# With authentication
bash wa-gate.sh

# Without authentication
bash wa-gate-noauth.sh
```

After installation, access the gateway at `http://YOUR_SERVER_IP:3000`.

## Configuration (wa-gate.sh)

Edit the variables at the top of `wa-gate.sh`:

```bash
WA_AUTH_USER="srnk"
WA_AUTH_PASS="srnkdgtl"
WA_PORT="3000"
```

## Requirements

- Ubuntu 22.04+ / Debian 12+
- Root access
- Minimum 1 GB RAM (for Go build)

## License

MIT
