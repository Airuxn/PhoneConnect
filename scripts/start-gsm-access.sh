#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

: "${POCKET_MCP_TARGET:?Set POCKET_MCP_TARGET to http://YOUR_TAILSCALE_IP:8080}"

bash "${DIR}/install-gsm-bridge.sh" 2>/dev/null || true
bash "${DIR}/start-tailscale.sh"

if ! pgrep -f phone-http-proxy.py >/dev/null 2>&1; then
  POCKET_MCP_TARGET="${POCKET_MCP_TARGET}" \
  ALL_PROXY="${ALL_PROXY:-socks5://127.0.0.1:1055}" \
    nohup python3 "${DIR}/phone-http-proxy.py" >>/tmp/phone-proxy.log 2>&1 &
  sleep 1
fi

health_url="${POCKET_MCP_TARGET%/}/health"
if curl -sf --socks5-hostname 127.0.0.1:1055 \
  -H "X-API-Key: ${POCKET_MCP_API_KEY:-}" \
  "${health_url}" >/dev/null 2>&1; then
  echo "GSM: phone OK via SOCKS"
else
  echo "GSM: phone NOT reachable"
fi

echo "GSM access ready. MCP via http://127.0.0.1:18090/mcp"
echo "Test: POCKET_MCP_URL=${POCKET_MCP_TARGET%/}/mcp node ${DIR}/gsm-api.mjs screen_state"
