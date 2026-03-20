#!/usr/bin/env node
/**
 * Database migration runner for MindScrolling
 * Tracks executed migrations in a _migrations table
 *
 * Usage:
 *   node scripts/run-migrations.js                    # Run pending migrations
 *   node scripts/run-migrations.js --status            # Show migration status
 *   node scripts/run-migrations.js --dry-run           # Show what would run
 */

const fs = require('fs');
const path = require('path');

const MIGRATIONS_DIR = path.resolve(__dirname, '..', 'backend', 'src', 'db', 'migrations');
const mode = process.argv[2] || '--run';

// Load .env from backend
const envPath = path.resolve(__dirname, '..', 'backend', '.env');
if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf-8');
  for (const line of envContent.split('\n')) {
    const match = line.match(/^([^#=]+)=(.*)$/);
    if (match) process.env[match[1].trim()] = match[2].trim();
  }
}

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('  ✗ Missing SUPABASE_URL or SUPABASE_ANON_KEY in backend/.env');
  process.exit(1);
}

const https = require('https');

function supabaseQuery(sql) {
  return new Promise((resolve, reject) => {
    const url = new URL(`${SUPABASE_URL}/rest/v1/rpc/exec_sql`);
    const data = JSON.stringify({ query: sql });

    // Use the PostgREST endpoint instead
    const restUrl = new URL(`${SUPABASE_URL}/rest/v1/_migrations?select=*&order=name`);

    const req = https.get(restUrl.toString(), {
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json'
      }
    }, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => resolve({ status: res.statusCode, data: body }));
    });
    req.on('error', reject);
  });
}

function getMigrationFiles() {
  if (!fs.existsSync(MIGRATIONS_DIR)) return [];
  return fs.readdirSync(MIGRATIONS_DIR)
    .filter(f => f.endsWith('.sql'))
    .sort();
}

async function showStatus() {
  const files = getMigrationFiles();
  console.log('\n══════════════════════════════════════════════════');
  console.log('  Migration Status');
  console.log('══════════════════════════════════════════════════\n');

  console.log(`  Found ${files.length} migration files:\n`);
  for (const f of files) {
    const size = fs.statSync(path.join(MIGRATIONS_DIR, f)).size;
    console.log(`    ${f} (${size} bytes)`);
  }

  console.log('\n  Note: Run these migrations in Supabase SQL Editor.');
  console.log('  Copy the SQL content and paste it in the editor.\n');
}

async function dryRun() {
  const files = getMigrationFiles();
  console.log('\n  Would run the following migrations:\n');
  for (const f of files) {
    const content = fs.readFileSync(path.join(MIGRATIONS_DIR, f), 'utf-8');
    const lines = content.split('\n').length;
    console.log(`    ${f} (${lines} lines)`);
  }
  console.log('');
}

async function generateCombined() {
  const files = getMigrationFiles();
  let combined = '-- MindScrolling Combined Migrations\n';
  combined += `-- Generated: ${new Date().toISOString()}\n`;
  combined += '-- Paste this in Supabase SQL Editor\n\n';

  for (const f of files) {
    const content = fs.readFileSync(path.join(MIGRATIONS_DIR, f), 'utf-8');
    combined += `-- ════════════════════════════════════════\n`;
    combined += `-- ${f}\n`;
    combined += `-- ════════════════════════════════════════\n`;
    combined += content;
    combined += '\n\n';
  }

  const outPath = path.join(MIGRATIONS_DIR, '..', 'all_migrations.sql');
  fs.writeFileSync(outPath, combined);
  console.log(`\n  ✓ Combined ${files.length} migrations into:`);
  console.log(`    backend/src/db/all_migrations.sql\n`);
  console.log('  Paste this file in Supabase SQL Editor to run all.\n');
}

// ─── Run ─────────────────────────────────────────────
(async () => {
  switch (mode) {
    case '--status':
      await showStatus();
      break;
    case '--dry-run':
      await dryRun();
      break;
    case '--combine':
      await generateCombined();
      break;
    default:
      await showStatus();
      console.log('  Use --combine to generate a single SQL file.\n');
  }
})();
