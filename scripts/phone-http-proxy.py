#!/usr/bin/env python3
"""Local HTTP proxy to PocketMCP on the phone via Tailscale SOCKS5."""

import os
import re
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

LISTEN_HOST = os.environ.get("PHONE_PROXY_HOST", "127.0.0.1")
LISTEN_PORT = int(os.environ.get("PHONE_PROXY_PORT", "18090"))
TARGET = os.environ.get("POCKET_MCP_TARGET", "").rstrip("/")
ALL_PROXY = os.environ.get("ALL_PROXY", "socks5://127.0.0.1:1055")

if not TARGET:
    print(
        "[phone-proxy] POCKET_MCP_TARGET is required (e.g. http://100.x.y.z:8080)",
        file=sys.stderr,
    )
    sys.exit(1)


def setup_socks() -> None:
    match = re.match(r"socks5h?://([^:/]+):(\d+)", ALL_PROXY)
    if not match:
        print(f"[phone-proxy] Invalid ALL_PROXY: {ALL_PROXY}", file=sys.stderr)
        sys.exit(1)

    import socks  # type: ignore
    import socket

    host, port = match.group(1), int(match.group(2))
    socks.set_default_proxy(socks.SOCKS5, host, port)
    socket.socket = socks.socksocket


class ProxyHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_GET(self) -> None:
        self._proxy()

    def do_POST(self) -> None:
        self._proxy()

    def _proxy(self) -> None:
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length) if length else None
        url = f"{TARGET}{self.path}"

        headers = {
            key: value
            for key, value in self.headers.items()
            if key.lower() not in ("host", "connection", "content-length", "transfer-encoding")
        }

        req = Request(url, data=body, headers=headers, method=self.command)
        try:
            with urlopen(req, timeout=60) as resp:
                data = resp.read()
                self.send_response(resp.status)
                for key, value in resp.headers.items():
                    if key.lower() not in ("transfer-encoding", "connection"):
                        self.send_header(key, value)
                self.end_headers()
                if data:
                    self.wfile.write(data)
        except HTTPError as err:
            payload = err.read()
            self.send_response(err.code)
            self.end_headers()
            if payload:
                self.wfile.write(payload)
        except URLError as err:
            self.send_response(502)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(str(err.reason or err).encode())

    def log_message(self, fmt: str, *args) -> None:
        sys.stderr.write(f"[phone-proxy] {self.address_string()} {fmt % args}\n")


def main() -> None:
    setup_socks()
    server = HTTPServer((LISTEN_HOST, LISTEN_PORT), ProxyHandler)
    print(
        f"[phone-proxy] {LISTEN_HOST}:{LISTEN_PORT} -> {TARGET} via {ALL_PROXY}",
        flush=True,
    )
    server.serve_forever()


if __name__ == "__main__":
    main()
