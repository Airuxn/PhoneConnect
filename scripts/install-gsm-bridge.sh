#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
BRIDGE_DIR="$(cd "${DIR}/../mcp-bridge" && pwd)"

chmod +x "${DIR}/phone-http-proxy.py" 2>/dev/null || true
chmod +x "${DIR}/start-gsm-access.sh" 2>/dev/null || true
chmod +x "${DIR}/start-tailscale.sh" 2>/dev/null || true
chmod +x "${DIR}/check-setup.sh" 2>/dev/null || true
chmod +x "${BRIDGE_DIR}/bridge.mjs" 2>/dev/null || true

command -v curl >/dev/null 2>&1 || {
  echo "install-gsm-bridge: curl is required" >&2
  exit 1
}

command -v node >/dev/null 2>&1 || command -v /exec-daemon/node >/dev/null 2>&1 || {
  echo "install-gsm-bridge: node is required" >&2
  exit 1
}

python3 -c "import socks" 2>/dev/null || {
  pip install -q pysocks 2>/dev/null || python3 -m pip install -q pysocks
}

echo "GSM bridge ready (phone-http-proxy + mcp-bridge)"
