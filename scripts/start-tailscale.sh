#!/usr/bin/env bash
set -euo pipefail

SOCKET="/var/run/tailscale/tailscaled.sock"
STATE_DIR="/var/lib/tailscale"
SOCKS_PORT="${GSM_SOCKS_PORT:-1055}"
HTTP_PROXY_PORT="${GSM_HTTP_PROXY_PORT:-1054}"
LOG="/tmp/tailscaled.log"

sudo mkdir -p /var/run/tailscale "${STATE_DIR}"

if [ -z "${TAILSCALE_AUTH_KEY:-}" ]; then
  echo "TAILSCALE_AUTH_KEY is not set" >&2
  exit 1
fi

if ! pgrep -x tailscaled >/dev/null 2>&1; then
  sudo sh -c "tailscaled \
    --tun=userspace-networking \
    --outbound-http-proxy-listen=127.0.0.1:${HTTP_PROXY_PORT} \
    --socks5-server=127.0.0.1:${SOCKS_PORT} \
    --state=${STATE_DIR}/tailscaled.state \
    --socket=${SOCKET} \
    >>${LOG} 2>&1" &
  sleep 3
fi

if ! sudo tailscale --socket="${SOCKET}" status >/dev/null 2>&1; then
  sudo tailscale --socket="${SOCKET}" up \
    --auth-key="${TAILSCALE_AUTH_KEY}" \
    --accept-routes \
    --accept-dns \
    --hostname="${TAILSCALE_HOSTNAME:-cursor-cloud-agent}" >/dev/null 2>&1 || true
  sleep 2
fi

echo "Tailscale ready (userspace + HTTP ${HTTP_PROXY_PORT} + SOCKS5 ${SOCKS_PORT})"
sudo tailscale --socket="${SOCKET}" status | head -20 || true
