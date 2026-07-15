#!/usr/bin/env node
/**
 * Call PocketMCP tools on an Android device via Tailscale SOCKS5.
 * Usage: node gsm-api.mjs screen_state
 *        node gsm-api.mjs device_info
 *        node gsm-api.mjs tap '{"x":720,"y":1200}'
 */
import { execFileSync } from 'node:child_process';

const tool = process.argv[2];
const argsJson = process.argv[3] || '{}';

if (!tool) {
  console.error('Usage: node gsm-api.mjs <tool> [json-args]');
  process.exit(1);
}

const API_KEY = process.env.POCKET_MCP_API_KEY;
if (!API_KEY) {
  console.error('POCKET_MCP_API_KEY is required');
  process.exit(1);
}

const url = process.env.POCKET_MCP_URL;
if (!url) {
  console.error('POCKET_MCP_URL is required (e.g. http://100.x.y.z:8080/mcp)');
  process.exit(1);
}
const socks = process.env.GSM_SOCKS_PORT || '1055';

const body = JSON.stringify({
  jsonrpc: '2.0',
  id: 1,
  method: 'tools/call',
  params: {
    name: tool,
    arguments: JSON.parse(argsJson),
  },
});

const out = execFileSync(
  'curl',
  [
    '-sS',
    '--max-time',
    '30',
    '--socks5-hostname',
    `localhost:${socks}`,
    '-H',
    `X-API-Key: ${API_KEY}`,
    '-H',
    'Content-Type: application/json',
    url,
    '-d',
    body,
  ],
  { encoding: 'utf8' }
);

console.log(JSON.stringify(JSON.parse(out), null, 2));
