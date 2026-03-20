#!/usr/bin/env node
/**
 * Database migration runner for MindScrolling
 * Executes migrations via Supabase Management API.
 * Tracks state in a _migrations table inside the database.
 *
 * Usage:
 *   node scripts/run-migrations.js                      # Run pending migrations
 *   node scripts/run-migrations.js --status             # Show migration status
 *   node scripts/run-migrations.js --dry-run            # Show what would run, no execution
 *   node scripts/run-migrations.js --run                # Run pending migrations (explicit)
 *   node scripts/run-migrations.js --run --force        # Re-run all, even already-recorded ones
 *   node scripts/run-migrations.js --run --yes          # Skip confirmation prompt (CI)
 *   node scripts/run-migrations.js --dry-run --yes      # Dry-run in CI (no prompt)
 *
 * Required environment variables:
 *   SUPABASE_ACCESS_TOKEN   — Personal access token from app.supabase.com/account/tokens
 *   SUPABASE_PROJECT_REF    — Project reference ID (e.g. rwhvjtfargojxccqblfb)
 *
 * Optional (loaded from backend/.env automatically if not already set):
 *   SUPABASE_URL            — Used to derive project ref if SUPABASE_PROJECT_REF is absent
 *   SUPABASE_SERVICE_KEY    — Not used directly; access token is required for Mgmt API
 */

'use strict';

const fs   = require('fs');
const path = require('path');
const https = require('https');
const crypto = require('crypto');
const readline = require('readline');

// ─── Configuration ────────────────────────────────────────────────────────────

const MIGRATIONS_DIR = path.resolve(__dirname, '..', 'backend', 'src', 'db', 'migrations');
const MGMT_API_BASE  = 'https://api.supabase.com/v1';
const PROD_REF       = 'rwhvjtfargojxccqblfb';

// ─── Parse CLI flags ──────────────────────────────────────────────────────────

const args  = process.argv.slice(2);
const force = args.includes('--force');
const yes   = args.includes('--yes');

let mode = '--run'; // default
if (args.includes('--status'))   mode = '--status';
else if (args.includes('--dry-run')) mode = '--dry-run';
else if (args.includes('--run'))  mode = '--run';

// ─── Load backend/.env if not already set ────────────────────────────────────

const envPath = path.resolve(__dirname, '..', 'backend', '.env');
if (fs.existsSync(envPath)) {
  const lines = fs.readFileSync(envPath, 'utf-8').split('\n');
  for (const line of lines) {
    const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (m && !process.env[m[1]]) {
      process.env[m[1]] = m[2].trim().replace(/^["']|["']$/g, '');
    }
  }
}

// ─── Resolve project ref ──────────────────────────────────────────────────────

function resolveProjectRef() {
  if (process.env.SUPABASE_PROJECT_REF) return process.env.SUPABASE_PROJECT_REF;
  // Derive from SUPABASE_URL: https://<ref>.supabase.co
  const url = process.env.SUPABASE_URL || '';
  const m = url.match(/https:\/\/([^.]+)\.supabase\.co/);
  if (m) return m[1];
  return null;
}

const ACCESS_TOKEN  = process.env.SUPABASE_ACCESS_TOKEN;
const PROJECT_REF   = resolveProjectRef();

// ─── Validate credentials ─────────────────────────────────────────────────────

function validateCredentials() {
  const errors = [];
  if (!ACCESS_TOKEN) {
    errors.push('SUPABASE_ACCESS_TOKEN is not set.');
    errors.push('  Get one at: https://app.supabase.com/account/tokens');
    errors.push('  Then set it in your environment or add to backend/.env');
  }
  if (!PROJECT_REF) {
    errors.push('SUPABASE_PROJECT_REF is not set (and could not be derived from SUPABASE_URL).');
  }
  if (errors.length) {
    console.error('\nConfiguration error:\n');
    errors.forEach(e => console.error('  ' + e));
    console.error('');
    process.exit(1);
  }
}

// ─── HTTP helper ──────────────────────────────────────────────────────────────

function httpRequest(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => { data += chunk; });
      res.on('end', () => {
        let parsed;
        try { parsed = JSON.parse(data); } catch { parsed = data; }
        resolve({ status: res.statusCode, headers: res.headers, body: parsed, raw: data });
      });
    });
    req.on('error', reject);
    if (body) req.write(typeof body === 'string' ? body : JSON.stringify(body));
    req.end();
  });
}

// ─── Supabase Management API: execute SQL ─────────────────────────────────────

async function execSQL(sql) {
  const payload = JSON.stringify({ query: sql });
  const options = {
    hostname: 'api.supabase.com',
    port: 443,
    path: `/v1/projects/${PROJECT_REF}/database/query`,
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${ACCESS_TOKEN}`,
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(payload),
    },
  };

  const res = await httpRequest(options, payload);

  // 200 or 201 = success
  if (res.status === 200 || res.status === 201) {
    return { ok: true, rows: Array.isArray(res.body) ? res.body : [] };
  }

  // Surface the error message clearly
  let errMsg = `HTTP ${res.status}`;
  if (res.body && res.body.message) errMsg += `: ${res.body.message}`;
  else if (res.body && res.body.error)   errMsg += `: ${res.body.error}`;
  else if (typeof res.body === 'string' && res.body.length < 500) errMsg += `: ${res.body}`;

  return { ok: false, error: errMsg, status: res.status };
}

// ─── Bootstrap _migrations table ─────────────────────────────────────────────

const BOOTSTRAP_SQL = `
CREATE TABLE IF NOT EXISTS _migrations (
  id           SERIAL PRIMARY KEY,
  name         TEXT NOT NULL UNIQUE,
  executed_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  checksum     TEXT NOT NULL
);
`;

async function bootstrap() {
  const result = await execSQL(BOOTSTRAP_SQL);
  if (!result.ok) {
    console.error(`\n  Failed to bootstrap _migrations table: ${result.error}`);
    console.error('  Ensure SUPABASE_ACCESS_TOKEN has the necessary permissions.\n');
    process.exit(1);
  }
}

// ─── Get already-executed migrations from DB ──────────────────────────────────

async function getExecutedMigrations() {
  const result = await execSQL('SELECT name, executed_at, checksum FROM _migrations ORDER BY name;');
  if (!result.ok) {
    // Table might not exist yet — return empty, bootstrap will create it
    return {};
  }
  const map = {};
  for (const row of result.rows) {
    map[row.name] = { executed_at: row.executed_at, checksum: row.checksum };
  }
  return map;
}

// ─── File helpers ─────────────────────────────────────────────────────────────

function getMigrationFiles() {
  if (!fs.existsSync(MIGRATIONS_DIR)) return [];
  return fs.readdirSync(MIGRATIONS_DIR)
    .filter(f => f.endsWith('.sql'))
    .sort();
}

function sha256(content) {
  return crypto.createHash('sha256').update(content, 'utf-8').digest('hex');
}

// ─── Confirmation prompt ──────────────────────────────────────────────────────

function confirm(question) {
  if (yes) return Promise.resolve(true);
  return new Promise((resolve) => {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    rl.question(question + ' [y/N] ', (answer) => {
      rl.close();
      resolve(answer.trim().toLowerCase() === 'y');
    });
  });
}

// ─── Display helpers ──────────────────────────────────────────────────────────

function pad(str, width) {
  return str.length >= width ? str : str + ' '.repeat(width - str.length);
}

function fmtDate(iso) {
  if (!iso) return 'never';
  return new Date(iso).toISOString().replace('T', ' ').slice(0, 19) + ' UTC';
}

// ─── Mode: --status ───────────────────────────────────────────────────────────

async function showStatus() {
  console.log('\n══════════════════════════════════════════════════════════════');
  console.log('  Migration Status — project: ' + PROJECT_REF);
  console.log('══════════════════════════════════════════════════════════════\n');

  await bootstrap();
  const executed = await getExecutedMigrations();
  const files    = getMigrationFiles();

  if (files.length === 0) {
    console.log('  No migration files found in ' + MIGRATIONS_DIR + '\n');
    return;
  }

  let pending = 0;
  console.log('  ' + pad('File', 45) + pad('Status', 10) + 'Executed At');
  console.log('  ' + '─'.repeat(80));

  for (const file of files) {
    const content  = fs.readFileSync(path.join(MIGRATIONS_DIR, file), 'utf-8');
    const checksum = sha256(content);
    const rec      = executed[file];

    let status;
    let detail = '';

    if (!rec) {
      status = 'PENDING';
      pending++;
    } else if (rec.checksum !== checksum) {
      status = 'MODIFIED';
      detail = ' (checksum mismatch — file changed after execution)';
    } else {
      status = 'applied';
    }

    console.log('  ' + pad(file, 45) + pad(status, 10) + fmtDate(rec && rec.executed_at) + detail);
  }

  console.log('');
  console.log(`  Total: ${files.length} files, ${pending} pending`);
  console.log('');
}

// ─── Mode: --dry-run ──────────────────────────────────────────────────────────

async function dryRun() {
  console.log('\n══════════════════════════════════════════════════════════════');
  console.log('  Dry Run — project: ' + PROJECT_REF);
  console.log('══════════════════════════════════════════════════════════════\n');

  await bootstrap();
  const executed = await getExecutedMigrations();
  const files    = getMigrationFiles();

  const pending = force
    ? files
    : files.filter(f => !executed[f]);

  if (pending.length === 0) {
    console.log('  No pending migrations. Database is up to date.\n');
    return;
  }

  console.log(`  Would execute ${pending.length} migration(s):\n`);
  for (const file of pending) {
    const content = fs.readFileSync(path.join(MIGRATIONS_DIR, file), 'utf-8');
    const lines   = content.split('\n').length;
    const cksum   = sha256(content).slice(0, 12);
    console.log(`    ${pad(file, 45)} ${lines} lines   sha256:${cksum}...`);
    if (force && executed[file]) {
      console.log(`    ${''.padStart(45)} (force re-run — already recorded)`);
    }
  }
  console.log('');
  console.log('  Run without --dry-run to execute.\n');
}

// ─── Mode: --run ──────────────────────────────────────────────────────────────

async function runMigrations() {
  console.log('\n══════════════════════════════════════════════════════════════');
  console.log('  Migration Runner — project: ' + PROJECT_REF);
  if (force) console.log('  WARNING: --force mode enabled, re-running all migrations');
  console.log('══════════════════════════════════════════════════════════════\n');

  // Production safety gate
  if (PROJECT_REF === PROD_REF && !yes) {
    console.log(`  This will execute SQL against the PRODUCTION database (${PROD_REF}).\n`);
    const ok = await confirm('  Are you sure you want to proceed?');
    if (!ok) {
      console.log('\n  Aborted by user.\n');
      process.exit(0);
    }
    console.log('');
  }

  await bootstrap();
  const executed = await getExecutedMigrations();
  const files    = getMigrationFiles();

  const pending = force
    ? files
    : files.filter(f => !executed[f]);

  if (pending.length === 0) {
    console.log('  No pending migrations. Database is up to date.\n');
    return;
  }

  console.log(`  Running ${pending.length} pending migration(s)...\n`);

  let passed = 0;
  let failed = 0;

  for (const file of pending) {
    const filePath = path.join(MIGRATIONS_DIR, file);
    const content  = fs.readFileSync(filePath, 'utf-8');
    const checksum = sha256(content);

    process.stdout.write(`  Running ${file} ... `);

    // Wrap in a transaction.
    // The Supabase Management API /database/query endpoint executes one statement
    // block per request. We wrap the migration SQL in BEGIN/COMMIT so that any
    // error inside the migration rolls back the entire file atomically.
    const transactional = `BEGIN;\n\n${content}\n\nCOMMIT;`;
    const result = await execSQL(transactional);

    if (!result.ok) {
      process.stdout.write('FAILED\n');
      console.error(`\n  Error: ${result.error}\n`);
      failed++;
      // Stop on first failure — do not proceed to later migrations
      console.error(`  Stopped after failure in ${file}.`);
      console.error('  Fix the error above, then re-run.\n');
      process.exit(1);
    }

    // Record the migration — insert or update (covers --force re-runs)
    const recordSQL = `
INSERT INTO _migrations (name, checksum, executed_at)
VALUES ('${file.replace(/'/g, "''")}', '${checksum}', now())
ON CONFLICT (name) DO UPDATE
  SET checksum     = EXCLUDED.checksum,
      executed_at  = EXCLUDED.executed_at;
`;
    const recordResult = await execSQL(recordSQL);
    if (!recordResult.ok) {
      process.stdout.write('WARN\n');
      console.warn(`  Warning: migration ran but failed to record in _migrations: ${recordResult.error}`);
      console.warn('  You may see this migration listed as PENDING on next run.\n');
    } else {
      process.stdout.write('ok\n');
      passed++;
    }
  }

  console.log('');
  console.log(`  Done. ${passed} migration(s) applied successfully.`);
  if (failed > 0) console.log(`  ${failed} migration(s) failed.`);
  console.log('');

  if (failed > 0) process.exit(1);
}

// ─── Entry point ─────────────────────────────────────────────────────────────

(async () => {
  validateCredentials();

  switch (mode) {
    case '--status':
      await showStatus();
      break;
    case '--dry-run':
      await dryRun();
      break;
    case '--run':
    default:
      await runMigrations();
      break;
  }
})().catch(err => {
  console.error('\n  Unexpected error:', err.message || err);
  process.exit(1);
});
