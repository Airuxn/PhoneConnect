# PhoneConnect

> ⚠️ **TEST PROJECT** ⚠️  
> Experimental setup for connecting an Android phone to a Cursor Cloud Agent. Not a production product.

Connect **your Android phone** to a **Cursor Cloud Agent** so the AI can use [PocketMCP](https://github.com/supermemoryai/pocketmcp) tools (tap, apps, screen state, and more) over a secure **Tailscale** link.

**Works for anyone** with: an Android device, a Tailscale account, and a Cursor Cloud Agent environment.

---

## What you get

- Cursor agent can **see and control your phone** through MCP (same idea as automating a device from the cloud).
- Traffic goes through **Tailscale SOCKS5** — required because direct cloud → phone TCP often fails.
- Open source bridge scripts + MCP stdio adapter — you configure secrets; nothing is hardcoded to one user or device.

---

## Quick start (5 steps)

### 1. Phone

- Install **Tailscale** + **PocketMCP** on Android.
- Set a PocketMCP **API key** in the app.
- Note your phone’s **Tailscale IP** (e.g. `100.x.y.z`).

### 2. Tailscale key

- Create an **auth key** at [login.tailscale.com/admin/settings/keys](https://login.tailscale.com/admin/settings/keys).

### 3. Cursor secrets

In **Cursor Dashboard → Cloud Agent → Environment → Secrets**:

```env
POCKET_MCP_API_KEY=<from PocketMCP app>
TAILSCALE_AUTH_KEY=<tskey-auth-...>
POCKET_MCP_TARGET=http://100.x.y.z:8080
NO_PROXY=127.0.0.1,localhost
```

Template: [`config/secrets.env.example`](config/secrets.env.example)

### 4. Cursor environment scripts

- **Update script:** paste [`scripts/environment-update.sh`](scripts/environment-update.sh)
- **MCP config:** copy [`config/mcp-android-phone.json.example`](config/mcp-android-phone.json.example) (set your API key)

### 5. Test

```bash
bash scripts/check-setup.sh
bash scripts/start-gsm-access.sh
POCKET_MCP_URL=$POCKET_MCP_TARGET/mcp node scripts/gsm-api.mjs screen_state
```

**Full walkthrough:** [**docs/setup-guide.md**](docs/setup-guide.md) (recommended for first-time setup)

---

## Architecture

```
Cursor MCP → bridge.mjs → http://127.0.0.1:18090/mcp (phone-http-proxy.py)
  → SOCKS5 127.0.0.1:1055 (Tailscale userspace)
  → http://YOUR_TAILSCALE_IP:8080 (PocketMCP on your phone)
```

---

## Repository layout

| Path | Description |
|------|-------------|
| [`scripts/check-setup.sh`](scripts/check-setup.sh) | Validate secrets, Tailscale, and phone reachability |
| [`scripts/start-gsm-access.sh`](scripts/start-gsm-access.sh) | Start proxy + health check |
| [`scripts/environment-update.sh`](scripts/environment-update.sh) | Paste into Cursor Environment |
| [`mcp-bridge/bridge.mjs`](mcp-bridge/bridge.mjs) | MCP stdio ↔ PocketMCP HTTP |
| [`docs/setup-guide.md`](docs/setup-guide.md) | Complete setup for any user |
| [`docs/memory/`](docs/memory/) | Optional agent playbooks |

---

## Using the agent on your phone

After setup, enable the **Android phone** MCP server in your cloud agent. The agent can call PocketMCP tools.

**Golden rule:** after every phone action → **`screen_state`** → verify → then continue.

---

## Requirements

| Component | Requirement |
|-----------|-------------|
| Phone | Android + PocketMCP + Tailscale |
| Cloud | Cursor Cloud Agent environment |
| Network | Phone and agent on the **same Tailscale tailnet** |
| Secrets | API key + Tailscale auth key + phone IP (`POCKET_MCP_TARGET`) |

---

## Security

PhoneConnect does **not** host a public website — there is no open API in this repo to attack. Safety depends on **how you configure secrets and Tailscale**:

- **Never commit real keys** — use [`config/secrets.env.example`](config/secrets.env.example) as a template only. Store values in **Cursor Dashboard → Environment → Secrets**.
- **`TAILSCALE_AUTH_KEY`** joins your tailnet. Anyone with this key can attempt to reach devices on that network. Use scoped/ephemeral keys where possible.
- **`POCKET_MCP_API_KEY`** grants control of PocketMCP on your phone (tap, apps, screen content). Treat it like a root password for the device.
- **Same tailnet required** — phone and cloud agent must share your Tailscale network; restrict access with [Tailscale ACLs](https://tailscale.com/kb/1018/acls).
- **Rotate immediately** if a key was ever pasted into git, chat, or a public file. See [SECURITY.md](SECURITY.md) for details and reporting.

There is no built-in rate limiting or multi-user auth — each deployment is a **private bridge** between **your** Cursor environment and **your** phone.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a Pull Request

---

## 📄 License

MIT License — see [LICENSE](LICENSE).

---

## 🙏 Acknowledgments

- [PocketMCP](https://github.com/supermemoryai/pocketmcp) — Android automation API
- [Tailscale](https://tailscale.com/) — secure connectivity
- [Cursor](https://cursor.com/) — Cloud Agents

---

## 📞 Support

- [Complete setup guide](docs/setup-guide.md)
- [Security](SECURITY.md)
- [GitHub Issues](https://github.com/Airuxn/PhoneConnect/issues)

---

**⭐ If this project helped you, please give it a star!**
