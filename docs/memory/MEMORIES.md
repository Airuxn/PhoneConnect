# Automation memory index

## Golden rule

**After every action on the phone → `screen_state` → verify → recover if needed.**

See [gsm-control-playbook.md](gsm-control-playbook.md).

## Setup guide

- **Markdown:** [../setup-guide.md](../setup-guide.md) — secrets, MCP, environment script

## Topics

- [gsm-control-playbook.md](gsm-control-playbook.md) — control rules + verify workflow
- [gsm-toegang.md](gsm-toegang.md) — Tailscale, PocketMCP bridge, connection
- [example-device-keyboard.md](example-device-keyboard.md) — optional example tap coordinates (adjust per device)

## Essentials

- Start Tailscale + SOCKS5 before MCP (`bash scripts/start-gsm-access.sh`)
- Secrets: `TAILSCALE_AUTH_KEY`, `POCKET_MCP_API_KEY`, `POCKET_MCP_TARGET`
- MCP URL for agents: `http://127.0.0.1:18090/mcp` (local proxy)
- Notification shade: `global_action notifications` (avoid blind swipe — power menu)
- Close shade: `global_action home` + verify launcher
- Never tap blindly — always verify via `screen_state`
