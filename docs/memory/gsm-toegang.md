# Device access — PocketMCP + Tailscale

## Phone (example)

- **Device**: your Android phone with PocketMCP (example docs use Samsung Galaxy Note8 layout)
- **Tailscale**: note your device name and **Tailscale IP** (e.g. `100.x.y.z`)
- **Port**: PocketMCP default `8080`
- **Auth**: `POCKET_MCP_API_KEY` as `X-API-Key` header

## Cloud agent connection

### Architecture

```
Cursor MCP → bridge.mjs (--url http://127.0.0.1:18090/mcp)
  → phone-http-proxy.py (127.0.0.1:18090)
  → SOCKS5 127.0.0.1:1055 (Tailscale userspace)
  → http://YOUR_TAILSCALE_IP:8080 (PocketMCP on phone)
```

### Environment update script

- Tailscale userspace + HTTP proxy `1054` + SOCKS5 `1055`
- `install-gsm-bridge.sh` + `phone-http-proxy.py`
- Health check via SOCKS5 to `$POCKET_MCP_TARGET/health`
- See `docs/setup-guide.md` and `scripts/environment-update.sh`

### MCP config (Android phone)

```json
{
  "command": "/exec-daemon/node",
  "args": ["/agent/mcp-bridge/bridge.mjs", "--url", "http://127.0.0.1:18090/mcp", "--verbose"],
  "env": { "POCKET_MCP_API_KEY": "...", "NO_PROXY": "127.0.0.1,localhost" }
}
```

### Manual start

- `bash scripts/start-gsm-access.sh` (requires `POCKET_MCP_TARGET`)
- Helper: `POCKET_MCP_URL=... node scripts/gsm-api.mjs screen_state`

### Important

- Direct TCP to the phone IP without SOCKS5 → often **Connection reset**
- Via SOCKS5: works when tailnet and keys are correct
- `take_screenshot` may fail on some devices → use `screen_state`

## Cursor Dashboard setup

1. Environment update script (`scripts/environment-update.sh`)
2. Secrets: `TAILSCALE_AUTH_KEY`, `POCKET_MCP_API_KEY`, `POCKET_MCP_TARGET`
3. MCP: **Android phone** via local proxy on port `18090`
