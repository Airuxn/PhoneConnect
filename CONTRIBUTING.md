# Contributing to PhoneConnect

Thanks for your interest in **PhoneConnect**.

## Before you start

- Read [README.md](README.md), [docs/setup-guide.md](docs/setup-guide.md), and [SECURITY.md](SECURITY.md).
- This project is **experimental** — breaking changes are acceptable with clear commit messages.
- Search [existing issues](https://github.com/Airuxn/PhoneConnect/issues) first.
- Do **not** file public issues for credential leaks — rotate keys and see SECURITY.md.

## Development setup

**Requirements:** bash, curl, Node.js 18+

```bash
git clone https://github.com/Airuxn/PhoneConnect.git
cd PhoneConnect
cp config/secrets.env.example config/secrets.env   # local only — never commit
# export vars from secrets.env, then:
bash scripts/check-setup.sh
node --check scripts/gsm-api.mjs
node --check mcp-bridge/bridge.mjs
```

Full integration testing requires a phone on your tailnet and a Cursor Cloud Agent environment.

## Pull requests

1. Fork and branch from `main`.
2. Keep scripts POSIX-safe where possible (`set -euo pipefail`).
3. Run CI checks locally: `shellcheck scripts/*.sh`, `node --check` on `.mjs` files.
4. Never commit real API keys or Tailscale auth keys — even in examples.

## Commit messages

```
Fix proxy health check when Tailscale starts slowly
Document screen_state golden rule in setup guide
```

## License

By contributing, you agree your contributions are licensed under the [MIT License](LICENSE).
