"""Minimal tests for scripts/phone-http-proxy.py.

These tests exercise the proxy helper without requiring a real phone or
network connection. They are intentionally lightweight; expand them as the
proxy grows.
"""

import importlib.util
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock

# The proxy script requires POCKET_MCP_TARGET to be set at import time.
os.environ.setdefault("POCKET_MCP_TARGET", "http://100.64.0.1:8080")
# Force a valid SOCKS5 proxy string so the helper functions can be exercised.
os.environ["ALL_PROXY"] = "socks5://127.0.0.1:1055"

_spec = importlib.util.spec_from_file_location(
    "phone_http_proxy", Path(__file__).parent.parent / "scripts" / "phone-http-proxy.py"
)
_phone_http_proxy = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_phone_http_proxy)


class TestSetupSocks(unittest.TestCase):
    def test_setup_socks_with_valid_proxy(self):
        mock_socks = MagicMock()
        mock_socks.SOCKS5 = 2
        mock_socks.socksocket = MagicMock()
        mock_socket = MagicMock()
        with patch.dict(sys.modules, {"socks": mock_socks, "socket": mock_socket}):
            _phone_http_proxy.setup_socks()
        mock_socks.set_default_proxy.assert_called_once_with(2, "127.0.0.1", 1055)
        self.assertEqual(mock_socket.socket, mock_socks.socksocket)

    def test_setup_socks_exits_on_invalid_proxy(self):
        original = _phone_http_proxy.ALL_PROXY
        _phone_http_proxy.ALL_PROXY = "http://invalid"
        try:
            with self.assertRaises(SystemExit):
                _phone_http_proxy.setup_socks()
        finally:
            _phone_http_proxy.ALL_PROXY = original


class TestProxyHandler(unittest.TestCase):
    def test_proxy_handler_exists(self):
        self.assertTrue(hasattr(_phone_http_proxy, "ProxyHandler"))
        self.assertTrue(hasattr(_phone_http_proxy.ProxyHandler, "do_GET"))
        self.assertTrue(hasattr(_phone_http_proxy.ProxyHandler, "do_POST"))


if __name__ == "__main__":
    unittest.main()
