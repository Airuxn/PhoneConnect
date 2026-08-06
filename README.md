# PhoneConnect

Experimental bridge: connect **your Android phone** to a **Cursor Cloud Agent** so the agent can use [PocketMCP](https://github.com/supermemoryai/pocketmcp) tools (tap, apps, screen state) over a **Tailscale** SOCKS5 link.

**Status:** experimental · **Requires:** Android + PocketMCP + Tailscale + Cursor Cloud Agent · [MIT](LICENSE)

[![CI](https://github.com/Airuxn/PhoneConnect/actions/workflows/ci.yml/badge.svg)](https://github.com/Airuxn/PhoneConnect/actions/workflows/ci.yml)

> Not a production product. API and scripts may change without notice.

---

## Quick start

### 1. Phone

- Install **Tailscale** + **PocketMCP** on Android.
- Set a PocketMCP **API key** in the app.
- Note your phone's **Tailscale IP** (e.g. `100.x.y.z`).

### 2. Tailscale key

Create an auth key at [login.tailscale.com/admin/settings/keys](https://login.tailscale.com/admin/settings/keys).

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

- **Update script:** [`scripts/environment-update.sh`](scripts/environment-update.sh)
- **MCP config:** [`config/mcp-android-phone.json.example`](config/mcp-android-phone.json.example) (set your API key)

### 5. Test

```bash
bash scripts/check-setup.sh
bash scripts/start-gsm-access.sh
POCKET_MCP_URL=$POCKET_MCP_TARGET/mcp node scripts/gsm-api.mjs screen_state
```

**First-time setup:** [docs/setup-guide.md](docs/setup-guide.md)

---

## What you get

- Cursor agent **sees and controls your phone** via MCP.
- Traffic uses **Tailscale SOCKS5** — direct cloud → phone TCP often fails without it.
- Open bridge scripts + MCP stdio adapter — secrets in Cursor env, nothing hardcoded to one user.

---

## Architecture

```
Cursor MCP → bridge.mjs → http://127.0.0.1:18090/mcp (phone-http-proxy.py)
  → SOCKS5 127.0.0.1:1055 (Tailscale userspace)
  → http://YOUR_TAILSCALE_IP:8080 (PocketMCP on phone)
```

---

## Repository layout

| Path | Description |
|------|-------------|
| [`scripts/check-setup.sh`](scripts/check-setup.sh) | Validate secrets, Tailscale, phone reachability |
| [`scripts/start-gsm-access.sh`](scripts/start-gsm-access.sh) | Start proxy + health check |
| [`scripts/environment-update.sh`](scripts/environment-update.sh) | Paste into Cursor Environment |
| [`mcp-bridge/bridge.mjs`](mcp-bridge/bridge.mjs) | MCP stdio ↔ PocketMCP HTTP |
| [`docs/setup-guide.md`](docs/setup-guide.md) | Complete setup walkthrough |
| [`docs/memory/`](docs/memory/) | Optional agent playbooks |

---

## Using the agent on your phone

Enable the **Android phone** MCP server in your cloud agent. After every phone action → call **`screen_state`** → verify → continue.

---

## Requirements

| Component | Requirement |
|-----------|-------------|
| Phone | Android + PocketMCP + Tailscale |
| Cloud | Cursor Cloud Agent environment |
| Network | Phone and agent on the **same Tailscale tailnet** |
| Secrets | API key + Tailscale auth key + `POCKET_MCP_TARGET` |

---

## Security

No public API in this repo — safety depends on **Tailscale ACLs** and **secret handling**. Never commit real keys; treat PocketMCP and Tailscale auth keys like root credentials for your phone.

See [SECURITY.md](SECURITY.md) for the security model, deployment guidance, and reporting.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [PocketMCP](https://github.com/supermemoryai/pocketmcp) — Android automation API
- [Tailscale](https://tailscale.com/) — secure connectivity
- [Cursor](https://cursor.com/) — Cloud Agents

---

## 📞 Support

For support and questions:

- [Complete setup guide](docs/setup-guide.md)
- Create an issue on [GitHub](https://github.com/Airuxn/PhoneConnect/issues)
- Security: see [SECURITY.md](SECURITY.md)

---

**⭐ If this project helped you, please give it a star!**
