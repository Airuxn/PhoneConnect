#!/usr/bin/env node
/**
 * MCP stdio bridge → PocketMCP (direct via SOCKS5 or via local phone-http-proxy).
 */
import { execFile } from 'node:child_process';
import { createInterface } from 'node:readline';

const args = process.argv.slice(2);
let phoneUrl = process.env.POCKET_MCP_URL || '';
let useSocks = true;
let verbose = false;

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--url' && args[i + 1]) {
    phoneUrl = args[++i];
    useSocks = false;
  } else if (args[i] === '--verbose') {
    verbose = true;
  }
}

const API_KEY = process.env.POCKET_MCP_API_KEY;
const SOCKS_PORT = process.env.GSM_SOCKS_PORT || '1055';

if (!API_KEY) {
  console.error('POCKET_MCP_API_KEY is required');
  process.exit(1);
}

if (!phoneUrl) {
  console.error('Set POCKET_MCP_URL or pass --url (e.g. http://127.0.0.1:18090/mcp)');
  process.exit(1);
}

function log(...parts) {
  if (verbose) console.error('[bridge]', ...parts);
}

function forward(message) {
  return new Promise((resolve, reject) => {
    const curlArgs = [
      '-sS',
      '--max-time',
      '60',
      '-H',
      `X-API-Key: ${API_KEY}`,
      '-H',
      'Content-Type: application/json',
    ];

    if (useSocks) {
      curlArgs.push('--socks5-hostname', `localhost:${SOCKS_PORT}`);
    }

    curlArgs.push(phoneUrl, '-d', message);

    log('POST', phoneUrl, useSocks ? `(SOCKS5 localhost:${SOCKS_PORT})` : '(local proxy)');

    execFile(
      'curl',
      curlArgs,
      { encoding: 'utf8', maxBuffer: 10 * 1024 * 1024 },
      (err, stdout, stderr) => {
        if (err) reject(new Error(stderr || err.message));
        else resolve(stdout.trim());
      }
    );
  });
}

const rl = createInterface({ input: process.stdin, crlfDelay: Infinity });
const queue = [];
let busy = false;

async function drain() {
  if (busy || queue.length === 0) return;
  busy = true;
  const line = queue.shift();
  try {
    const response = await forward(line);
    process.stdout.write(response + '\n');
  } catch (err) {
    let id = null;
    try {
      id = JSON.parse(line).id ?? null;
    } catch {
      /* ignore */
    }
    log('error', err?.message || err);
    process.stdout.write(
      JSON.stringify({
        jsonrpc: '2.0',
        id,
        error: { code: -32000, message: String(err?.message || err) },
      }) + '\n'
    );
  } finally {
    busy = false;
    drain();
  }
}

rl.on('line', (line) => {
  const trimmed = line.trim();
  if (!trimmed) return;
  queue.push(trimmed);
  drain();
});
