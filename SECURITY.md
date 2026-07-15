# Security Policy

## Reporting a Vulnerability

If you discover a security issue, please **do not** open a public GitHub issue.

Contact the maintainer privately via GitHub Security Advisories or direct message.

## Security Model

PhoneConnect bridges a **Cursor Cloud Agent** to an **Android device** running [PocketMCP](https://github.com/supermemoryai/pocketmcp) over **Tailscale**:

- **Tailscale pre-auth key** (`TAILSCALE_AUTH_KEY`) — grants network access to your tailnet. Treat as a secret; use ephemeral/reusable keys with minimal scope.
- **PocketMCP API key** (`POCKET_MCP_API_KEY`) — sent as `X-API-Key` on every request to the phone. Anyone with this key and tailnet access can control the device.
- **No app-level user authentication** — security depends on tailnet membership, API keys, and who can run the cloud agent environment.

Traffic from the cloud agent to the phone **must** use Tailscale SOCKS5 (`127.0.0.1:1055`). Direct TCP to the phone IP often fails and bypasses the intended path.

## Before Deploying

1. Never commit real keys — use `config/secrets.env.example` as a template only.
2. Store secrets in **Cursor Dashboard → Environment → Secrets**, not in HTML, scripts, or git.
3. Use a dedicated Tailscale auth key and PocketMCP API key per environment; rotate if exposed.
4. Restrict tailnet ACLs so only trusted devices/users can reach the phone.
5. The cloud agent can invoke PocketMCP tools (tap, launch apps, read screen state) — only connect devices you are willing to automate.

## If Keys Were Ever Committed

Revoke and rotate **immediately**:

- Tailscale: [Admin console → Keys](https://login.tailscale.com/admin/settings/keys)
- PocketMCP: regenerate the API key in the app on the device
