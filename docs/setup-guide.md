# PhoneConnect — Complete setup guide

Use this guide to connect **your** Android phone (with [PocketMCP](https://github.com/supermemoryai/pocketmcp)) to a **Cursor Cloud Agent**.

**Time:** ~30 minutes the first time.  
**You need:** Android phone, Tailscale account (free tier works), Cursor account with Cloud Agents.

---

## Overview

| Step | Where | What |
|------|--------|------|
| 1 | Phone | Install Tailscale + PocketMCP |
| 2 | Phone | Note Tailscale IP + API key |
| 3 | Tailscale admin | Create auth key for cloud agent |
| 4 | Cursor Dashboard | Add secrets + update script + MCP |
| 5 | Cloud agent | Run check + test |

---

## Step 1 — Phone apps

### Tailscale

1. Install [Tailscale](https://tailscale.com/download/android) on your Android device.
2. Log in with the **same tailnet** you will use for the cloud agent.
3. Keep the app running / allow background activity so the node stays online.

### PocketMCP

1. Install PocketMCP on the same device.
2. Open **Settings** → set an **API key** (pick a long random string — you will reuse it in Cursor).
3. Start the server (default port **8080** unless you changed it).
4. Allow battery optimization exceptions if the server stops in the background.

---

## Step 2 — Find your phone’s Tailscale IP

On the phone: Tailscale app → your device → note the **100.x.y.z** address.

Or from any machine on the same tailnet:

```bash
tailscale status
```

Set:

```text
POCKET_MCP_TARGET=http://100.x.y.z:8080
```

(Replace `100.x.y.z` with your phone’s IP and `8080` if you use another port.)

**Test from a PC on the tailnet** (optional):

```bash
curl -H "X-API-Key: YOUR_POCKET_MCP_API_KEY" http://100.x.y.z:8080/health
```

---

## Step 3 — Tailscale auth key (for cloud agent)

1. Open [Tailscale admin → Keys](https://login.tailscale.com/admin/settings/keys).
2. **Generate auth key** — reusable is fine for a personal cloud environment; use ephemeral for stricter setups.
3. Copy the key (`tskey-auth-...`) — this becomes `TAILSCALE_AUTH_KEY`.

The cloud agent joins **your** tailnet so it can reach the phone over SOCKS5.

---

## Step 4 — Cursor Cloud Agent environment

### 4a. Clone / attach this repo

Your cloud agent environment must include this repository (or copy `scripts/` and `mcp-bridge/` to `/agent/` paths expected below).

### 4b. Secrets

**Cursor Dashboard → Cloud Agents → your Environment → Secrets**

```env
POCKET_MCP_API_KEY=your-pocketmcp-api-key-from-phone
TAILSCALE_AUTH_KEY=tskey-auth-your-key-from-step-3
POCKET_MCP_TARGET=http://100.x.y.z:8080
NO_PROXY=127.0.0.1,localhost
```

Copy the template from `config/secrets.env.example`. **Never commit real values to git.**

### 4c. Update script

**Environment → Update script** — paste the full contents of `scripts/environment-update.sh`.

This installs Tailscale (userspace), starts SOCKS5 on `127.0.0.1:1055`, and runs `phone-http-proxy.py` on port `18090`.

### 4d. MCP server

**Environment → MCP** — add (adjust paths if your repo layout differs):

```json
{
  "mcpServers": {
    "Android phone": {
      "command": "/exec-daemon/node",
      "args": [
        "/agent/mcp-bridge/bridge.mjs",
        "--url",
        "http://127.0.0.1:18090/mcp",
        "--verbose"
      ],
      "env": {
        "POCKET_MCP_API_KEY": "YOUR_POCKET_MCP_API_KEY",
        "NO_PROXY": "127.0.0.1,localhost"
      }
    }
  }
}
```

Or use `config/mcp-android-phone.json.example`.

The MCP server talks to the **local proxy** (`18090`), not directly to the phone IP — that is intentional.

---

## Step 5 — Verify

In a cloud agent shell:

```bash
bash /agent/scripts/check-setup.sh
bash /agent/scripts/start-gsm-access.sh
POCKET_MCP_URL=$POCKET_MCP_TARGET/mcp node /agent/scripts/gsm-api.mjs screen_state
```

Expected:

- `check-setup.sh` → no FAIL lines
- `start-gsm-access.sh` → `GSM: phone OK via SOCKS`
- `screen_state` → JSON with current screen info

In Cursor chat, the **Android phone** MCP tools should appear (tap, launch_app, screen_state, etc.).

---

## How to use (daily)

1. Keep the phone **online** on Tailscale with PocketMCP running.
2. Start or wake your cloud agent (update script runs automatically).
3. Ask the agent to use phone tools — e.g. “open Chrome and …”.
4. **Golden rule:** after each action, use `screen_state` to verify before continuing.

See `docs/memory/gsm-control-playbook.md` for agent behaviour tips.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|----------------|-----|
| `Set POCKET_MCP_TARGET` | Secret missing | Add `POCKET_MCP_TARGET` in Cursor secrets |
| `Connection reset` to phone IP | Direct TCP without SOCKS5 | Use proxy path (`18090`) or SOCKS5 curl |
| `phone NOT reachable` | Phone offline / wrong IP / API key | Check Tailscale app, IP, PocketMCP key |
| MCP tools missing | MCP config not loaded | Re-check Environment MCP JSON |
| `POCKET_MCP_API_KEY is required` | Secret not injected | Set secret in Dashboard, restart environment |
| Tailscale fails | Invalid or expired auth key | Generate new key in Tailscale admin |

Run `bash scripts/check-setup.sh` for a quick diagnosis.

---

## Security reminders

- Only connect devices you trust the agent to control.
- Restrict tailnet access with [Tailscale ACLs](https://tailscale.com/kb/1018/acls) if you share a tailnet.
- Rotate keys if they were ever leaked. See [SECURITY.md](../SECURITY.md).

---

## Optional — example keyboard coordinates

If you automate typing on a specific device, add coordinates under `docs/memory/` (see `example-device-keyboard.md` as a starting template). Coordinates are **device-specific** — adjust for your phone and keyboard app.
