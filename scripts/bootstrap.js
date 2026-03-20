#!/usr/bin/env node
/**
 * MindScrolling — New Developer Bootstrap
 *
 * Usage:
 *   node scripts/bootstrap.js
 *
 * What it does:
 *   1. Check prerequisites (Node, npm, git, Flutter, gh)
 *   2. Install backend dependencies (npm ci)
 *   3. Install Flutter dependencies (flutter pub get)
 *   4. Set up backend/.env from .env.example
 *   5. Install git hooks
 *   6. Verify the backend starts and responds on /health
 *   7. Run environment doctor
 *   8. Print summary
 *
 * Cross-platform: works on Windows 11 and Unix.
 */

'use strict';

const { execSync, spawnSync, spawn } = require('child_process');
const fs   = require('fs');
const path = require('path');
const http = require('http');

// ─── Paths ────────────────────────────────────────────────────────────────────

const ROOT    = path.resolve(__dirname, '..');
const BACKEND = path.join(ROOT, 'backend');
const FLUTTER = path.join(ROOT, 'flutter_app');

// ─── Colours (no external deps) ───────────────────────────────────────────────

const IS_CI = process.env.CI === 'true' || process.env.CI === '1';

const c = {
  reset:  IS_CI ? '' : '\x1b[0m',
  bold:   IS_CI ? '' : '\x1b[1m',
  dim:    IS_CI ? '' : '\x1b[2m',
  cyan:   IS_CI ? '' : '\x1b[36m',
  green:  IS_CI ? '' : '\x1b[32m',
  yellow: IS_CI ? '' : '\x1b[33m',
  red:    IS_CI ? '' : '\x1b[31m',
  blue:   IS_CI ? '' : '\x1b[34m',
  white:  IS_CI ? '' : '\x1b[37m',
};

// ─── Output helpers ───────────────────────────────────────────────────────────

function line(ch = '─', len = 60) {
  return ch.repeat(len);
}

function header(stepNum, total, title) {
  console.log('');
  console.log(`${c.cyan}${line('═')}${c.reset}`);
  console.log(`${c.bold}${c.cyan}  Step ${stepNum}/${total}: ${title}${c.reset}`);
  console.log(`${c.cyan}${line('═')}${c.reset}`);
}

function ok(msg) {
  console.log(`  ${c.green}✓${c.reset} ${msg}`);
}

function warn(msg) {
  console.log(`  ${c.yellow}!${c.reset} ${msg}`);
}

function fail(msg) {
  console.log(`  ${c.red}✗${c.reset} ${msg}`);
}

function info(msg) {
  console.log(`  ${c.dim}${msg}${c.reset}`);
}

function step(msg) {
  console.log(`  ${c.blue}→${c.reset} ${msg}`);
}

// ─── Results tracker ──────────────────────────────────────────────────────────

const results = [];

function record(stepName, status, detail = '') {
  results.push({ stepName, status, detail });
}

// ─── Utility: run a command and capture stdout ─────────────────────────────────

function tryExec(cmd, opts = {}) {
  try {
    return execSync(cmd, {
      encoding: 'utf-8',
      timeout: opts.timeout || 30000,
      stdio: opts.stdio || 'pipe',
      env: { ...process.env, ...(opts.env || {}) },
      cwd: opts.cwd || ROOT,
    }).trim();
  } catch {
    return null;
  }
}

// ─── Step 1: Prerequisites ────────────────────────────────────────────────────

// Flutter binary: try the Windows path first, then fall back to PATH.
const FLUTTER_CANDIDATES = [
  'C:\\flutter\\flutter\\bin\\flutter.bat',
  'C:\\src\\flutter\\bin\\flutter.bat',
  'flutter',        // already on PATH (Unix / custom install)
  'flutter.bat',    // on PATH on Windows
];

function findFlutter() {
  for (const candidate of FLUTTER_CANDIDATES) {
    const out = tryExec(`"${candidate}" --version`, { timeout: 20000 });
    if (out) return { bin: candidate, version: out.split('\n')[0].trim() };
  }
  return null;
}

function checkPrerequisites() {
  header(1, 7, 'Checking Prerequisites');

  const prereqs = [
    {
      name: 'Node.js',
      key:  'node',
      cmd:  'node --version',
      required: true,
      validate: (v) => {
        const match = v.match(/v(\d+)/);
        if (!match) return 'Cannot parse version';
        if (parseInt(match[1], 10) < 20) return `v${match[1]} found — Node.js 20+ required`;
        return null;
      },
    },
    {
      name: 'npm',
      key:  'npm',
      cmd:  'npm --version',
      required: true,
    },
    {
      name: 'Git',
      key:  'git',
      cmd:  'git --version',
      required: true,
    },
    {
      name: 'gh CLI',
      key:  'gh',
      cmd:  'gh --version',
      required: false,
    },
  ];

  const found = {};

  for (const p of prereqs) {
    const out = tryExec(p.cmd, { timeout: 10000 });
    if (!out) {
      if (p.required) {
        fail(`${p.name}: NOT FOUND (required)`);
        found[p.key] = false;
      } else {
        warn(`${p.name}: not found (optional — some workflow commands will not work)`);
        found[p.key] = false;
      }
      continue;
    }

    if (p.validate) {
      const err = p.validate(out);
      if (err) {
        fail(`${p.name}: ${err}`);
        found[p.key] = false;
        continue;
      }
    }

    ok(`${p.name}: ${out.split('\n')[0]}`);
    found[p.key] = true;
  }

  // Flutter — special handling because the binary path varies
  step('Searching for Flutter...');
  const flutter = findFlutter();
  if (flutter) {
    ok(`Flutter: ${flutter.version}  (${flutter.bin})`);
    found.flutter     = true;
    found.flutterBin  = flutter.bin;
  } else {
    warn('Flutter: NOT FOUND — Flutter steps will be skipped.');
    warn('Install from https://docs.flutter.dev/get-started/install');
    found.flutter    = false;
    found.flutterBin = null;
  }

  const allRequired = found.node && found.npm && found.git;
  if (allRequired) {
    record('Prerequisites', 'ok');
  } else {
    record('Prerequisites', 'fail', 'One or more required tools missing — install them and re-run');
  }

  return found;
}

// ─── Step 2: Backend dependencies ────────────────────────────────────────────

function installBackendDeps() {
  header(2, 7, 'Installing Backend Dependencies');

  const lockFile = path.join(BACKEND, 'package-lock.json');
  const cmd = fs.existsSync(lockFile) ? 'npm ci' : 'npm install';
  info(`Using: ${cmd}  (cwd: backend/)`);

  const result = spawnSync(cmd, {
    cwd:   BACKEND,
    stdio: 'inherit',
    shell: true,
    timeout: 120000,
  });

  if (result.status === 0) {
    ok('Backend dependencies installed');
    record('Backend deps', 'ok');
  } else {
    fail('npm install failed — check output above');
    record('Backend deps', 'fail', `${cmd} exited with code ${result.status}`);
  }
}

// ─── Step 3: Flutter dependencies ────────────────────────────────────────────

function installFlutterDeps(flutterBin) {
  header(3, 7, 'Installing Flutter Dependencies');

  if (!flutterBin) {
    warn('Flutter not found — skipping pub get');
    record('Flutter deps', 'skip', 'Flutter binary not found');
    return;
  }

  info(`Using: "${flutterBin}" pub get  (cwd: flutter_app/)`);

  const result = spawnSync(`"${flutterBin}" pub get`, {
    cwd:   FLUTTER,
    stdio: 'inherit',
    shell: true,
    timeout: 180000,
  });

  if (result.status === 0) {
    ok('Flutter dependencies installed');
    record('Flutter deps', 'ok');
  } else {
    fail('"flutter pub get" failed — check output above');
    record('Flutter deps', 'fail', `Exited with code ${result.status}`);
  }
}

// ─── Step 4: .env setup ───────────────────────────────────────────────────────

// These keys have safe local-dev defaults (no real credentials required).
const ENV_DEFAULTS = {
  PORT:                      '3000',
  ALLOWED_ORIGIN:            'http://localhost:5173',
  PREMIUM_PLAN_NAME:         'MindScrolling Inside',
  PREMIUM_BASE_PRICE_USD:    '4.99',
  PREMIUM_PRODUCT_ID_ANDROID: 'com.mindscrolling.inside',
  PREMIUM_PRODUCT_ID_IOS:    'com.mindscrolling.inside',
  SENTRY_DSN:                '',
  REVENUECAT_WEBHOOK_SECRET: '',
};

// These need real values before the server is useful in production.
const MANUAL_KEYS = [
  'SUPABASE_URL',
  'SUPABASE_ANON_KEY',
  'VOYAGE_API_KEY',
  'ANTHROPIC_API_KEY',
  'ADMIN_SECRET',
];

function setupEnv() {
  header(4, 7, 'Setting Up Backend .env');

  const envPath     = path.join(BACKEND, '.env');
  const examplePath = path.join(BACKEND, '.env.example');

  if (fs.existsSync(envPath)) {
    ok('.env already exists — skipping copy');
    record('.env setup', 'ok', 'Already present');
    return;
  }

  if (!fs.existsSync(examplePath)) {
    fail('.env.example not found — cannot create .env');
    record('.env setup', 'fail', '.env.example missing');
    return;
  }

  // Read .env.example and apply safe defaults
  let content = fs.readFileSync(examplePath, 'utf-8');

  for (const [key, value] of Object.entries(ENV_DEFAULTS)) {
    // Replace lines like KEY=anything with KEY=default
    content = content.replace(
      new RegExp(`^(${key}=).*$`, 'm'),
      `$1${value}`
    );
  }

  fs.writeFileSync(envPath, content, 'utf-8');

  ok('.env created from .env.example');
  console.log('');
  warn('The following variables need REAL values before the server can');
  warn('connect to Supabase and external APIs:');
  console.log('');
  for (const key of MANUAL_KEYS) {
    console.log(`    ${c.yellow}${key}${c.reset}`);
  }
  console.log('');
  info(`Edit: ${envPath}`);

  record('.env setup', 'warn', `Created with defaults — fill in: ${MANUAL_KEYS.join(', ')}`);
}

// ─── Step 5: Git hooks ────────────────────────────────────────────────────────

function installGitHooks() {
  header(5, 7, 'Installing Git Hooks');

  const hookScript = path.join(ROOT, 'scripts', 'install-hooks.js');
  if (!fs.existsSync(hookScript)) {
    warn('scripts/install-hooks.js not found — skipping');
    record('Git hooks', 'skip', 'install-hooks.js not found');
    return;
  }

  const result = spawnSync('node scripts/install-hooks.js', {
    cwd:   ROOT,
    stdio: 'inherit',
    shell: true,
    timeout: 15000,
  });

  if (result.status === 0) {
    ok('Git hooks installed');
    record('Git hooks', 'ok');
  } else {
    fail('Hook installation failed — check output above');
    record('Git hooks', 'fail', `Exited with code ${result.status}`);
  }
}

// ─── Step 6: Verify backend starts ────────────────────────────────────────────

function waitForHealth(port, timeoutMs) {
  return new Promise((resolve) => {
    const deadline = Date.now() + timeoutMs;

    function attempt() {
      if (Date.now() > deadline) {
        resolve(false);
        return;
      }
      const req = http.get(`http://127.0.0.1:${port}/health`, { timeout: 2000 }, (res) => {
        let body = '';
        res.on('data', (chunk) => { body += chunk; });
        res.on('end', () => {
          try {
            const json = JSON.parse(body);
            resolve(json.status === 'ok');
          } catch {
            resolve(res.statusCode === 200);
          }
        });
      });
      req.on('error', () => {
        setTimeout(attempt, 500);
      });
      req.on('timeout', () => {
        req.destroy();
        setTimeout(attempt, 500);
      });
    }

    attempt();
  });
}

async function verifyBackend() {
  header(6, 7, 'Verifying Backend Startup');

  const envPath = path.join(BACKEND, '.env');
  if (!fs.existsSync(envPath)) {
    warn('No .env found — skipping startup check');
    record('Backend verify', 'skip', '.env missing');
    return;
  }

  // Read .env to find port
  const envContent = fs.readFileSync(envPath, 'utf-8');
  const portMatch  = envContent.match(/^PORT=(\d+)/m);
  const port       = portMatch ? parseInt(portMatch[1], 10) : 3000;

  info(`Starting backend on port ${port} for smoke test...`);
  info('(Logs below are from the server — this is normal)');
  console.log('');

  // Use spawn so we can kill it ourselves
  const serverProc = spawn('node', ['src/app.js'], {
    cwd:   BACKEND,
    stdio: 'inherit',
    shell: false,
    env:   { ...process.env },
    detached: false,
  });

  let serverExitCode = null;
  serverProc.on('exit', (code) => {
    serverExitCode = code;
  });

  // Give the server up to 12 seconds to respond
  const healthy = await waitForHealth(port, 12000);

  // Kill the server regardless of outcome
  try {
    if (process.platform === 'win32') {
      spawnSync('taskkill', ['/PID', String(serverProc.pid), '/F', '/T'], { shell: true, stdio: 'pipe' });
    } else {
      serverProc.kill('SIGTERM');
    }
  } catch {
    // Best-effort kill
  }

  // Brief pause to let the process exit cleanly before next output
  await new Promise((r) => setTimeout(r, 600));
  console.log('');

  if (healthy) {
    ok(`GET /health responded { status: "ok" } on port ${port}`);
    record('Backend verify', 'ok');
  } else if (serverExitCode !== null && serverExitCode !== 0) {
    fail('Backend exited before responding — likely missing .env credentials');
    warn('Fill in SUPABASE_URL and SUPABASE_ANON_KEY in backend/.env then re-run');
    record('Backend verify', 'fail', 'Server crashed — check .env credentials');
  } else {
    fail(`No response on port ${port} within 12 seconds`);
    warn('The server may be starting slowly or .env values are placeholder text');
    record('Backend verify', 'warn', '/health did not respond in time');
  }
}

// ─── Step 7: Doctor ───────────────────────────────────────────────────────────

function runDoctor() {
  header(7, 7, 'Running Environment Doctor');

  const result = spawnSync('node scripts/workflow.js doctor', {
    cwd:   ROOT,
    stdio: 'inherit',
    shell: true,
    timeout: 30000,
  });

  if (result.status === 0) {
    record('Doctor', 'ok');
  } else {
    record('Doctor', 'warn', 'doctor exited non-zero — review output above');
  }
}

// ─── Summary ──────────────────────────────────────────────────────────────────

function printSummary() {
  console.log('');
  console.log(`${c.cyan}${line('═')}${c.reset}`);
  console.log(`${c.bold}${c.cyan}  Bootstrap Summary${c.reset}`);
  console.log(`${c.cyan}${line('═')}${c.reset}`);
  console.log('');

  const manualItems = [];

  for (const r of results) {
    if (r.status === 'ok') {
      ok(`${r.stepName}`);
    } else if (r.status === 'skip') {
      console.log(`  ${c.dim}-${c.reset} ${r.stepName}: skipped${r.detail ? ' — ' + r.detail : ''}`);
    } else if (r.status === 'warn') {
      warn(`${r.stepName}${r.detail ? ' — ' + r.detail : ''}`);
      manualItems.push(r);
    } else {
      fail(`${r.stepName}${r.detail ? ' — ' + r.detail : ''}`);
      manualItems.push(r);
    }
  }

  console.log('');

  if (manualItems.length === 0) {
    console.log(`${c.green}${c.bold}  All steps completed successfully.${c.reset}`);
    console.log('');
    console.log('  Next steps:');
    console.log(`    ${c.cyan}node scripts/workflow.js dev${c.reset}   — start the backend dev server`);
    console.log(`    ${c.cyan}node scripts/workflow.js doctor${c.reset} — re-check environment at any time`);
  } else {
    console.log(`${c.yellow}${c.bold}  Bootstrap complete with items needing attention:${c.reset}`);
    console.log('');

    // Always remind about .env if it was freshly created
    const envResult = results.find((r) => r.stepName === '.env setup' && r.status === 'warn');
    if (envResult) {
      console.log(`  ${c.yellow}[Manual]${c.reset} Fill in credentials in ${path.join(BACKEND, '.env')}:`);
      for (const key of MANUAL_KEYS) {
        console.log(`           ${c.yellow}${key}${c.reset}`);
      }
      console.log('');
      console.log(`           Supabase:   https://supabase.com → Project Settings → API`);
      console.log(`           Voyage AI:  https://dash.voyageai.com`);
      console.log(`           Anthropic:  https://console.anthropic.com`);
      console.log('');
    }

    for (const r of manualItems) {
      if (r.stepName === '.env setup') continue; // already printed above
      console.log(`  ${c.yellow}[${r.status === 'fail' ? 'Failed' : 'Warn'}]${c.reset} ${r.stepName}: ${r.detail}`);
    }

    console.log('');
    console.log('  After filling in .env, run:');
    console.log(`    ${c.cyan}node scripts/workflow.js dev${c.reset}`);
    console.log(`    ${c.cyan}node scripts/workflow.js doctor${c.reset}`);
  }

  console.log('');
  console.log(`${c.dim}${line()}${c.reset}`);
  console.log(`${c.dim}  Migration order reminder (run in Supabase SQL editor):${c.reset}`);
  console.log(`${c.dim}  001_initial.sql → 002_fix_swipe_dir.sql → 003_feed_algorithm.sql → 004_ai_feed.sql${c.reset}`);
  console.log(`${c.dim}  (004 requires the pgvector extension enabled in Supabase Dashboard)${c.reset}`);
  console.log(`${c.dim}${line()}${c.reset}`);
  console.log('');
}

// ─── Main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log('');
  console.log(`${c.bold}${c.cyan}  MindScrolling — Developer Bootstrap${c.reset}`);
  console.log(`${c.dim}  Setting up your local development environment...${c.reset}`);

  const prereqs = checkPrerequisites();

  installBackendDeps();
  installFlutterDeps(prereqs.flutterBin);
  setupEnv();
  installGitHooks();
  await verifyBackend();
  runDoctor();
  printSummary();
}

main().catch((err) => {
  console.error(`\n${c.red}  Fatal bootstrap error:${c.reset}`, err.message || err);
  process.exit(1);
});
