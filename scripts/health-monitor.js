#!/usr/bin/env node
/**
 * Backend health monitor for MindScrolling
 *
 * Usage:
 *   node scripts/health-monitor.js              # Single check
 *   node scripts/health-monitor.js --watch      # Check every 5 minutes
 *   node scripts/health-monitor.js --endpoints  # Check all endpoints
 */

const https = require('https');
const http = require('http');

const BASE_URL = 'https://mindscrolling.onrender.com';
const DEVICE_ID = '00000000-0000-0000-0000-000000000000';

const mode = process.argv[2];

function fetch(url, options = {}) {
  return new Promise((resolve, reject) => {
    const mod = url.startsWith('https') ? https : http;
    const req = mod.get(url, {
      headers: {
        'x-device-id': DEVICE_ID,
        'Accept-Language': 'en',
        ...options.headers
      },
      timeout: 15000
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        resolve({ status: res.statusCode, data, url });
      });
    });
    req.on('error', (e) => reject(e));
    req.on('timeout', () => { req.destroy(); reject(new Error('Timeout')); });
  });
}

async function checkHealth() {
  const start = Date.now();
  try {
    const { status, data } = await fetch(`${BASE_URL}/health`);
    const ms = Date.now() - start;

    if (status === 200) {
      const parsed = JSON.parse(data);
      console.log(`  ✓ Health OK (${ms}ms) — ${parsed.ts}`);
      return true;
    } else {
      console.log(`  ✗ Health FAILED — status ${status} (${ms}ms)`);
      return false;
    }
  } catch (e) {
    const ms = Date.now() - start;
    console.log(`  ✗ Health UNREACHABLE — ${e.message} (${ms}ms)`);
    return false;
  }
}

async function checkAllEndpoints() {
  const endpoints = [
    { path: '/health', expected: 200 },
    { path: '/api/quotes/feed?lang=en', expected: 200 },
    { path: '/api/quotes/feed?lang=es', expected: 200 },
    { path: '/api/authors', expected: 200 },
    { path: '/api/packs', expected: 200 },
    { path: '/api/challenges/today', expected: 200 },
    { path: '/api/stats', expected: 200 },
    { path: '/api/premium/status', expected: 200 },
    { path: '/api/vault', expected: 200 },
    { path: '/api/profile', expected: 200 },
    { path: '/api/mind-profile/daily', expected: 200 },
  ];

  console.log('\n══════════════════════════════════════════════════');
  console.log('  MindScrolling Endpoint Health Check');
  console.log(`  ${new Date().toISOString()}`);
  console.log('══════════════════════════════════════════════════\n');

  let passed = 0;
  let failed = 0;

  for (const { path: ep, expected } of endpoints) {
    const start = Date.now();
    try {
      const { status } = await fetch(`${BASE_URL}${ep}`);
      const ms = Date.now() - start;

      if (status === expected) {
        console.log(`  ✓ ${ep} — ${status} (${ms}ms)`);
        passed++;
      } else {
        console.log(`  ✗ ${ep} — ${status} expected ${expected} (${ms}ms)`);
        failed++;
      }
    } catch (e) {
      console.log(`  ✗ ${ep} — ${e.message}`);
      failed++;
    }
  }

  console.log(`\n  Results: ${passed}/${endpoints.length} passed`);

  if (failed > 0) {
    console.log(`  ⚠ ${failed} endpoints failing!\n`);
    process.exit(1);
  } else {
    console.log('  ✓ All endpoints healthy!\n');
  }
}

async function watch() {
  const INTERVAL = 5 * 60 * 1000; // 5 minutes
  console.log('  Monitoring backend health every 5 minutes...\n');

  let consecutiveFailures = 0;

  const tick = async () => {
    const ok = await checkHealth();
    if (!ok) {
      consecutiveFailures++;
      if (consecutiveFailures >= 3) {
        console.log(`  ⚠ ALERT: Backend down for ${consecutiveFailures} consecutive checks!`);
      }
    } else {
      consecutiveFailures = 0;
    }
  };

  await tick();
  setInterval(tick, INTERVAL);
}

// ─── Run ─────────────────────────────────────────────
(async () => {
  if (mode === '--watch') {
    await watch();
  } else if (mode === '--endpoints') {
    await checkAllEndpoints();
  } else {
    await checkHealth();
  }
})();
