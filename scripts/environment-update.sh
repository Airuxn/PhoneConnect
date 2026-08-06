#!/usr/bin/env bash
# Paste this into Cursor Dashboard → Environment → Update script
# Requires secrets: TAILSCALE_AUTH_KEY, POCKET_MCP_API_KEY, POCKET_MCP_TARGET

set -euo pipefail

: "${POCKET_MCP_TARGET:?Set POCKET_MCP_TARGET in Environment secrets (http://YOUR_TAILSCALE_IP:8080)}"

sudo mkdir -p /var/run/tailscale /var/lib/tailscale
command -v tailscale >/dev/null 2>&1 || curl -fsSL https://tailscale.com/install.sh | sh
pip install -q pysocks || python3 -m pip install -q pysocks

bash /agent/scripts/install-gsm-bridge.sh 2>/dev/null || true

if ! pgrep -x tailscaled >/dev/null; then
  sudo tailscaled --tun=userspace-networking \
    --outbound-http-proxy-listen=127.0.0.1:1054 \
    --socks5-server=127.0.0.1:1055 \
    --state=/var/lib/tailscale/tailscaled.state \
    --socket=/var/run/tailscale/tailscaled.sock &
  sleep 3
fi

if [[ -n "${TAILSCALE_AUTH_KEY:-}" ]]; then
  sudo tailscale --socket=/var/run/tailscale/tailscaled.sock up \
    --auth-key="$TAILSCALE_AUTH_KEY" --accept-routes --accept-dns --hostname=cursor-cloud-agent || true
fi

if ! pgrep -f phone-http-proxy.py >/dev/null; then
  POCKET_MCP_TARGET="$POCKET_MCP_TARGET" \
  ALL_PROXY="socks5://127.0.0.1:1055" \
    nohup python3 /agent/scripts/phone-http-proxy.py >>/tmp/phone-proxy.log 2>&1 &
  sleep 1
fi

health_url="${POCKET_MCP_TARGET%/}/health"
curl -sf --socks5-hostname 127.0.0.1:1055 \
  -H "X-API-Key: ${POCKET_MCP_API_KEY:-}" \
  "$health_url" >/dev/null \
  && echo "GSM: phone OK via SOCKS" || echo "GSM: phone NOT reachable"
