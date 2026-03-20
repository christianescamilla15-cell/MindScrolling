#!/usr/bin/env node
/**
 * MindScrolling Automated QA Runner
 *
 * Runs all automated quality checks in sequence and produces a structured
 * JSON report. Designed to be called by the QA phase of the sprint workflow
 * or standalone before a release.
 *
 * Usage:
 *   node scripts/qa-runner.js              # Run all checks
 *   node scripts/qa-runner.js --fix        # Run checks + auto-fix what is possible
 *   node scripts/qa-runner.js --summary    # Print last report summary only
 *
 * Exit codes:
 *   0 — all checks passed
 *   1 — one or more checks failed
 */

'use strict';

const fs           = require('fs');
const path         = require('path');
const { execSync } = require('child_process');
const https        = require('https');
const http         = require('http');

const ROOT        = path.resolve(__dirname, '..');
const BACKEND     = path.join(ROOT, 'backend');
const FLUTTER     = path.join(ROOT, 'flutter_app');
const REPORTS_DIR = path.join(ROOT, '.qa-reports');
const FLUTTER_BIN = 'C:\\flutter\\flutter\\bin\\flutter.bat';
const BASE_URL    = process.env.BACKEND_URL || 'https://mindscrolling.onrender.com';
const DEVICE_ID   = '00000000-0000-0000-0000-000000000000';

const FIX_MODE     = process.argv.includes('--fix');
const SUMMARY_MODE = process.argv.includes('--summary');

// ─── Utilities ────────────────────────────────────────────────────────────────

function header(text) {
  console.log(`\n${'─'.repeat(54)}`);
  console.log(`  ${text}`);
  console.log('─'.repeat(54));
}

function nowIso() {
  return new Date().toISOString();
}

function dateSuffix() {
  return new Date().toISOString().slice(0, 10);
}

/**
 * Run a shell command. Returns { ok, stdout, stderr, durationMs }.
 * Never throws — failures are returned as ok:false.
 */
function shell(command, cwd = ROOT, timeoutMs = 60000) {
  const start = Date.now();
  try {
    const stdout = execSync(command, {
      cwd,
      encoding: 'utf-8',
      timeout: timeoutMs,
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    return { ok: true, stdout: stdout || '', stderr: '', durationMs: Date.now() - start };
  } catch (e) {
    return {
      ok: false,
      stdout: e.stdout || '',
      stderr: e.stderr || e.message || '',
      durationMs: Date.now() - start,
    };
  }
}

/**
 * Simple HTTP/HTTPS GET. Returns { status, body, durationMs } or throws.
 */
function httpGet(url, headers = {}) {
  return new Promise((resolve, reject) => {
    const mod = url.startsWith('https') ? https : http;
    const start = Date.now();
    const req = mod.get(url, { headers, timeout: 10000 }, (res) => {
      let body = '';
      res.on('data', chunk => { body += chunk; });
      res.on('end', () => resolve({ status: res.statusCode, body, durationMs: Date.now() - start }));
    });
    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('HTTP timeout')); });
  });
}

// ─── Result accumulator ───────────────────────────────────────────────────────

const results = [];

function record(checkName, passed, details = '', autoFixed = false) {
  const icon = passed ? '  PASS' : '  FAIL';
  const fixTag = autoFixed ? ' [auto-fixed]' : '';
  console.log(`${icon}  ${checkName}${fixTag}`);
  if (!passed && details) {
    // Indent detail lines
    details.split('\n').slice(0, 8).forEach(l => console.log(`        ${l}`));
  }
  results.push({ check: checkName, passed, details, autoFixed, timestamp: nowIso() });
  return passed;
}

// ─── Checks ──────────────────────────────────────────────────────────────────

/**
 * 1. Backend syntax — all route, service, util files
 */
function checkBackendSyntax() {
  header('1. Backend Syntax Check');

  const dirsToCheck = [
    { dir: path.join(BACKEND, 'src', 'routes'),   prefix: 'src/routes' },
    { dir: path.join(BACKEND, 'src', 'services'), prefix: 'src/services' },
    { dir: path.join(BACKEND, 'src', 'utils'),    prefix: 'src/utils' },
    { dir: path.join(BACKEND, 'src', 'plugins'),  prefix: 'src/plugins' },
  ];

  let allPassed = true;

  for (const { dir, prefix } of dirsToCheck) {
    if (!fs.existsSync(dir)) continue;

    const files = fs.readdirSync(dir).filter(f => f.endsWith('.js'));
    for (const f of files) {
      const rel = `${prefix}/${f}`;
      const res = shell(`node --check ${rel}`, BACKEND);
      if (!record(`Syntax: ${rel}`, res.ok, res.stderr.trim())) {
        allPassed = false;
      }
    }
  }

  // Also check app.js / server.js at root
  for (const entry of ['src/app.js', 'src/server.js', 'src/index.js']) {
    if (fs.existsSync(path.join(BACKEND, entry))) {
      const res = shell(`node --check ${entry}`, BACKEND);
      if (!record(`Syntax: ${entry}`, res.ok, res.stderr.trim())) {
        allPassed = false;
      }
    }
  }

  return allPassed;
}

/**
 * 2. Backend tests
 */
function checkBackendTests() {
  header('2. Backend Tests (npm test)');
  const res = shell('npm test', BACKEND, 120000);
  const detail = (res.stdout + '\n' + res.stderr).trim();
  return record('Backend: npm test', res.ok, detail);
}

/**
 * 3. Flutter analyze
 */
function checkFlutterAnalyze() {
  header('3. Flutter Analyze');

  // Auto-fix: flutter format if --fix
  if (FIX_MODE) {
    console.log('  [--fix] Running flutter format...');
    shell(`"${FLUTTER_BIN}" format lib/`, FLUTTER, 120000);
  }

  const res = shell(`"${FLUTTER_BIN}" analyze --no-fatal-infos`, FLUTTER, 180000);
  const combined = (res.stdout + '\n' + res.stderr).trim();

  // Parse error/warning count from output
  const errorMatch  = combined.match(/(\d+)\s+error/i);
  const warningMatch = combined.match(/(\d+)\s+warning/i);
  const errorCount  = errorMatch  ? parseInt(errorMatch[1])   : 0;
  const warnCount   = warningMatch ? parseInt(warningMatch[1]) : 0;

  const passed = res.ok && errorCount === 0;
  const detail = passed
    ? `0 errors, ${warnCount} warnings`
    : `${errorCount} errors, ${warnCount} warnings\n${combined.slice(0, 600)}`;

  return record('Flutter: analyze (no errors)', passed, detail, FIX_MODE);
}

/**
 * 4. Security scan — check for leaked secrets
 */
function checkSecrets() {
  header('4. Security Scan (leaked secrets)');
  let allPassed = true;

  // Patterns that should not appear in committed code
  const secretPatterns = [
    { label: 'Anthropic API key (sk-ant-)',       pattern: 'sk-ant-' },
    { label: 'Supabase JWT (eyJhbGci)',           pattern: 'eyJhbGci' },
    { label: 'Hardcoded password',                pattern: 'password\\s*=\\s*["\'][^"\']{6,}' },
    { label: 'Voyage AI key (pa-)',               pattern: 'pa-[A-Za-z0-9]{20}' },
    { label: 'AWS secret key',                    pattern: 'AKIA[0-9A-Z]{16}' },
    { label: 'Generic private key header',        pattern: '-----BEGIN (RSA |EC )?PRIVATE KEY' },
  ];

  // Files/dirs to scan (exclude node_modules, build, .git)
  const scanTargets = [
    path.join(ROOT, 'backend', 'src'),
    path.join(ROOT, 'flutter_app', 'lib'),
    path.join(ROOT, 'scripts'),
  ];

  for (const { label, pattern } of secretPatterns) {
    let found = false;
    const matches = [];

    for (const target of scanTargets) {
      if (!fs.existsSync(target)) continue;
      // Use node --check compatible approach: walk files manually
      found = found || scanDir(target, pattern, matches);
    }

    if (!record(`Security: no ${label}`, !found, matches.slice(0, 3).join('\n'))) {
      allPassed = false;
    }
  }

  // Check .env is not tracked by git
  const gitTracked = shell('git ls-files | grep -E "^\\.env$" || true', ROOT);
  const envTracked = gitTracked.stdout.trim().length > 0;
  if (!record('Security: .env not tracked by git', !envTracked, envTracked ? '.env is git-tracked!' : '')) {
    allPassed = false;
  }

  return allPassed;
}

function scanDir(dir, pattern, matches) {
  let found = false;
  try {
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        if (!['node_modules', 'build', '.git', '.dart_tool'].includes(entry.name)) {
          if (scanDir(full, pattern, matches)) found = true;
        }
      } else if (entry.isFile() && /\.(js|dart|ts|json|yaml|yml|env)$/.test(entry.name)) {
        try {
          const content = fs.readFileSync(full, 'utf-8');
          const re = new RegExp(pattern, 'i');
          if (re.test(content)) {
            found = true;
            matches.push(`${full} matches /${pattern}/`);
          }
        } catch { /* binary or unreadable */ }
      }
    }
  } catch { /* permission errors */ }
  return found;
}

/**
 * 5. API health check (if backend is reachable)
 */
async function checkApiHealth() {
  header('5. API Endpoint Health Check');

  const endpoints = [
    { path: '/health',                  method: 'GET', expected: 200, requiresDevice: false },
    { path: '/api/quotes/feed?lang=en', method: 'GET', expected: 200, requiresDevice: true  },
    { path: '/api/authors',             method: 'GET', expected: 200, requiresDevice: true  },
    { path: '/api/packs',               method: 'GET', expected: 200, requiresDevice: true  },
    { path: '/api/challenges/today',    method: 'GET', expected: 200, requiresDevice: true  },
    { path: '/api/stats',               method: 'GET', expected: 200, requiresDevice: true  },
    { path: '/api/premium/status',      method: 'GET', expected: 200, requiresDevice: true  },
    { path: '/api/vault',               method: 'GET', expected: 200, requiresDevice: true  },
    { path: '/api/profile',             method: 'GET', expected: 200, requiresDevice: true  },
  ];

  // First: check if backend is reachable at all
  let reachable = false;
  try {
    const { status } = await httpGet(`${BASE_URL}/health`, {});
    reachable = status === 200;
  } catch {
    reachable = false;
  }

  if (!reachable) {
    record(
      'API: backend reachable',
      false,
      `${BASE_URL}/health did not respond. Skipping endpoint checks.\n` +
      `Set BACKEND_URL env var to point to a running instance.`
    );
    // Not a fatal failure — backend may not be running locally
    return true;
  }

  record('API: backend reachable', true);

  let allPassed = true;
  for (const ep of endpoints) {
    const headers = ep.requiresDevice ? { 'x-device-id': DEVICE_ID } : {};
    try {
      const { status, durationMs } = await httpGet(`${BASE_URL}${ep.path}`, headers);
      const passed = status === ep.expected;
      if (!record(
        `API: ${ep.method} ${ep.path}`,
        passed,
        passed ? '' : `Expected ${ep.expected}, got ${status} (${durationMs}ms)`
      )) {
        allPassed = false;
      }
    } catch (e) {
      record(`API: ${ep.method} ${ep.path}`, false, e.message);
      allPassed = false;
    }
  }

  return allPassed;
}

/**
 * 6. Pre-release checks (delegate to pre-release-check.js)
 */
function checkPreRelease() {
  header('6. Pre-Release Checklist');
  const res = shell('node scripts/pre-release-check.js', ROOT, 60000);
  const combined = (res.stdout + '\n' + res.stderr).trim();

  // Extract pass/fail count from output
  const match = combined.match(/Results:\s*(\d+)\s*passed,\s*(\d+)\s*failed/);
  let detail = '';
  if (match) {
    detail = `${match[1]} passed, ${match[2]} failed`;
  } else {
    detail = combined.slice(0, 400);
  }

  return record('Pre-release: all checks', res.ok, detail);
}

// ─── Report ───────────────────────────────────────────────────────────────────

function writeReport() {
  if (!fs.existsSync(REPORTS_DIR)) {
    fs.mkdirSync(REPORTS_DIR, { recursive: true });
  }

  const passed  = results.filter(r => r.passed).length;
  const failed  = results.filter(r => !r.passed).length;
  const fixed   = results.filter(r => r.autoFixed).length;
  const allPass = failed === 0;

  const report = {
    generatedAt:  nowIso(),
    fixMode:      FIX_MODE,
    summary: {
      total:    results.length,
      passed,
      failed,
      autoFixed: fixed,
      verdict:  allPass ? 'PASS' : 'FAIL',
    },
    checks: results,
  };

  const reportPath = path.join(REPORTS_DIR, `qa-report-${dateSuffix()}.json`);
  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));

  // Also write a Markdown summary for the sprint handoff
  const mdLines = [
    `# QA Report`,
    `**Generated:** ${report.generatedAt}`,
    `**Verdict:** ${report.summary.verdict}`,
    `**Results:** ${passed} passed, ${failed} failed${fixed > 0 ? `, ${fixed} auto-fixed` : ''}`,
    ``,
    `## Checks`,
    ``,
    `| Check | Result | Notes |`,
    `|-------|--------|-------|`,
    ...results.map(r => {
      const status  = r.passed ? 'PASS' : 'FAIL';
      const notes   = r.autoFixed ? 'auto-fixed' : (r.details ? r.details.split('\n')[0].slice(0, 80) : '');
      return `| ${r.check} | ${status} | ${notes} |`;
    }),
    ``,
    `## Failed Checks`,
    ``,
    ...(failed === 0
      ? ['All checks passed.']
      : results
          .filter(r => !r.passed)
          .map(r => [`### ${r.check}`, ``, r.details || '(no details)', ``])
          .flat()
    ),
  ];

  const mdPath = path.join(REPORTS_DIR, `qa-report-${dateSuffix()}.md`);
  fs.writeFileSync(mdPath, mdLines.join('\n'));

  return { reportPath, mdPath, allPass, passed, failed };
}

function printSummary(file) {
  if (!fs.existsSync(file)) {
    console.log('\n  No QA report found. Run: node scripts/qa-runner.js\n');
    return;
  }
  const report = JSON.parse(fs.readFileSync(file, 'utf-8'));
  console.log(`\n  QA Report — ${report.generatedAt}`);
  console.log(`  Verdict: ${report.summary.verdict}`);
  console.log(`  ${report.summary.passed} passed / ${report.summary.failed} failed\n`);
  const failed = report.checks.filter(c => !c.passed);
  if (failed.length > 0) {
    console.log('  Failed checks:');
    failed.forEach(c => console.log(`    - ${c.check}`));
  }
  console.log('');
}

// ─── Summary-only mode ────────────────────────────────────────────────────────

if (SUMMARY_MODE) {
  const latestReport = path.join(REPORTS_DIR, `qa-report-${dateSuffix()}.json`);
  printSummary(latestReport);
  process.exit(0);
}

// ─── Main ─────────────────────────────────────────────────────────────────────

(async () => {
  console.log('\n' + '='.repeat(54));
  console.log('  MindScrolling QA Runner');
  console.log(`  ${nowIso()}`);
  if (FIX_MODE) console.log('  Mode: --fix (auto-fixing enabled)');
  console.log('='.repeat(54));

  // Run all checks
  checkBackendSyntax();
  checkBackendTests();
  checkFlutterAnalyze();
  checkSecrets();
  await checkApiHealth();
  checkPreRelease();

  // Write report
  const { reportPath, mdPath, allPass, passed, failed } = writeReport();

  // Final summary
  console.log(`\n${'='.repeat(54)}`);
  console.log(`  QA Summary`);
  console.log('='.repeat(54));
  console.log(`  Total checks : ${results.length}`);
  console.log(`  Passed       : ${passed}`);
  console.log(`  Failed       : ${failed}`);
  if (FIX_MODE) {
    console.log(`  Auto-fixed   : ${results.filter(r => r.autoFixed).length}`);
  }
  console.log('');

  if (!allPass) {
    console.log('  Failed checks:');
    results.filter(r => !r.passed).forEach(r => {
      console.log(`    - ${r.check}`);
      if (r.details) {
        r.details.split('\n').slice(0, 2).forEach(l => console.log(`        ${l}`));
      }
    });
    console.log('');
  }

  console.log(`  Verdict: ${allPass ? 'PASS — ready for release' : 'FAIL — fix issues above'}`);
  console.log(`  Report:  ${reportPath}`);
  console.log(`  Markdown: ${mdPath}`);
  console.log('');

  process.exit(allPass ? 0 : 1);
})();
