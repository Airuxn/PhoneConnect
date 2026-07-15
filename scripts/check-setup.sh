#!/usr/bin/env bash
# Validate PhoneConnect environment and phone reachability.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
OK=0
WARN=0
FAIL=0

pass() { echo "  OK   $1"; OK=$((OK + 1)); }
warn() { echo "  WARN $1"; WARN=$((WARN + 1)); }
fail() { echo "  FAIL $1"; FAIL=$((FAIL + 1)); }

echo "PhoneConnect setup check"
echo "========================"

for var in POCKET_MCP_API_KEY TAILSCALE_AUTH_KEY POCKET_MCP_TARGET; do
  if [[ -n "${!var:-}" ]]; then
    pass "$var is set"
  else
    fail "$var is not set (see docs/setup-guide.md)"
  fi
done

if command -v curl >/dev/null 2>&1; then pass "curl found"; else fail "curl missing"; fi
if command -v node >/dev/null 2>&1 || command -v /exec-daemon/node >/dev/null 2>&1; then
  pass "node found"
else
  fail "node missing"
fi
if python3 -c "import socks" 2>/dev/null; then pass "pysocks installed"; else warn "pysocks missing (pip install pysocks)"; fi

if pgrep -x tailscaled >/dev/null 2>&1; then
  pass "tailscaled running"
else
  warn "tailscaled not running (run scripts/start-tailscale.sh)"
fi

if pgrep -f phone-http-proxy.py >/dev/null 2>&1; then
  pass "phone-http-proxy running"
else
  warn "phone-http-proxy not running (run scripts/start-gsm-access.sh)"
fi

if [[ -n "${POCKET_MCP_TARGET:-}" && -n "${POCKET_MCP_API_KEY:-}" ]]; then
  health_url="${POCKET_MCP_TARGET%/}/health"
  if curl -sf --socks5-hostname 127.0.0.1:1055 \
    -H "X-API-Key: ${POCKET_MCP_API_KEY}" \
    "${health_url}" >/dev/null 2>&1; then
    pass "phone health OK via SOCKS5 (${health_url})"
  else
    fail "phone not reachable at ${health_url} via SOCKS5 — check Tailscale, PocketMCP, and IP"
  fi
fi

if curl -sf http://127.0.0.1:18090/health >/dev/null 2>&1 || \
   curl -sf -o /dev/null -w '' http://127.0.0.1:18090/mcp 2>/dev/null; then
  pass "local MCP proxy responds on :18090"
else
  warn "nothing on http://127.0.0.1:18090 yet (start scripts/start-gsm-access.sh)"
fi

echo "------------------------"
echo "Result: ${OK} ok, ${WARN} warnings, ${FAIL} failures"
if [[ "$FAIL" -gt 0 ]]; then
  echo "Fix failures above, then see docs/setup-guide.md"
  exit 1
fi
exit 0
