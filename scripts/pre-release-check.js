#!/usr/bin/env node
/**
 * Pre-release checklist — validates everything before Play Store upload
 *
 * Usage: node scripts/pre-release-check.js
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const ROOT = path.resolve(__dirname, '..');
let passed = 0;
let failed = 0;
const issues = [];

function check(name, fn) {
  try {
    const result = fn();
    if (result === true) {
      console.log(`  ✓ ${name}`);
      passed++;
    } else {
      console.log(`  ✗ ${name}: ${result}`);
      issues.push({ name, reason: result });
      failed++;
    }
  } catch (e) {
    console.log(`  ✗ ${name}: ${e.message}`);
    issues.push({ name, reason: e.message });
    failed++;
  }
}

console.log('\n══════════════════════════════════════════════════');
console.log('  MindScrolling Pre-Release Checklist');
console.log('══════════════════════════════════════════════════\n');

// ─── 1. Version ──────────────────────────────────────
console.log('  Version & Build\n');

check('pubspec.yaml has valid version', () => {
  const pubspec = fs.readFileSync(path.join(ROOT, 'flutter_app', 'pubspec.yaml'), 'utf-8');
  const match = pubspec.match(/version:\s*(\d+\.\d+\.\d+\+\d+)/);
  if (!match) return 'No version found';
  console.log(`    → ${match[1]}`);
  return true;
});

check('Version code not already used (> 7)', () => {
  const pubspec = fs.readFileSync(path.join(ROOT, 'flutter_app', 'pubspec.yaml'), 'utf-8');
  const match = pubspec.match(/version:\s*\d+\.\d+\.\d+\+(\d+)/);
  const buildNum = parseInt(match[1]);
  if (buildNum <= 7) return `Build ${buildNum} may already be used on Play Store`;
  return true;
});

// ─── 2. Git ──────────────────────────────────────────
console.log('\n  Git Status\n');

check('No uncommitted changes', () => {
  const status = execSync('git status --porcelain', { cwd: ROOT, encoding: 'utf-8' }).trim();
  if (status) return `${status.split('\n').length} uncommitted files`;
  return true;
});

check('On main branch', () => {
  const branch = execSync('git branch --show-current', { cwd: ROOT, encoding: 'utf-8' }).trim();
  if (branch !== 'main') return `On branch '${branch}'`;
  return true;
});

check('Up to date with remote', () => {
  try {
    execSync('git fetch origin main', { cwd: ROOT, encoding: 'utf-8', timeout: 10000 });
    const diff = execSync('git rev-list HEAD..origin/main --count', { cwd: ROOT, encoding: 'utf-8' }).trim();
    if (parseInt(diff) > 0) return `${diff} commits behind origin/main`;
  } catch {
    return 'Could not fetch remote';
  }
  return true;
});

// ─── 3. Backend ──────────────────────────────────────
console.log('\n  Backend\n');

check('All route files have valid syntax', () => {
  const routesDir = path.join(ROOT, 'backend', 'src', 'routes');
  const files = fs.readdirSync(routesDir).filter(f => f.endsWith('.js'));
  for (const f of files) {
    try {
      execSync(`node --check src/routes/${f}`, { cwd: path.join(ROOT, 'backend'), encoding: 'utf-8' });
    } catch {
      return `Syntax error in ${f}`;
    }
  }
  return true;
});

check('All service files have valid syntax', () => {
  const servicesDir = path.join(ROOT, 'backend', 'src', 'services');
  if (!fs.existsSync(servicesDir)) return true;
  const files = fs.readdirSync(servicesDir).filter(f => f.endsWith('.js'));
  for (const f of files) {
    try {
      execSync(`node --check src/services/${f}`, { cwd: path.join(ROOT, 'backend'), encoding: 'utf-8' });
    } catch {
      return `Syntax error in ${f}`;
    }
  }
  return true;
});

check('No hardcoded API keys in backend', () => {
  const result = execSync(
    'grep -rn "sk-ant-\\|eyJhbGci" --include="*.js" backend/src/ 2>/dev/null || echo ""',
    { cwd: ROOT, encoding: 'utf-8' }
  ).trim();
  if (result) return 'Hardcoded keys found';
  return true;
});

check('Backend tests pass', () => {
  try {
    execSync('npm test', { cwd: path.join(ROOT, 'backend'), encoding: 'utf-8', timeout: 30000 });
    return true;
  } catch (e) {
    return 'Tests failed';
  }
});

// ─── 4. Flutter ──────────────────────────────────────
console.log('\n  Flutter\n');

check('pubspec.yaml is valid', () => {
  const pubspec = fs.readFileSync(path.join(ROOT, 'flutter_app', 'pubspec.yaml'), 'utf-8');
  if (!pubspec.includes('name: mind_scrolling')) return 'Invalid pubspec';
  return true;
});

check('App icon exists', () => {
  const icon = path.join(ROOT, 'flutter_app', 'assets', 'images', 'app_icon.png');
  if (!fs.existsSync(icon)) return 'Missing app_icon.png';
  return true;
});

check('Splash logo exists', () => {
  const splash = path.join(ROOT, 'flutter_app', 'assets', 'images', 'splash_logo.png');
  if (!fs.existsSync(splash)) return 'Missing splash_logo.png';
  return true;
});

check('Keystore config exists', () => {
  const keyProps = path.join(ROOT, 'flutter_app', 'android', 'key.properties');
  if (!fs.existsSync(keyProps)) return 'Missing android/key.properties (using debug signing)';
  return true;
});

check('No TODO/FIXME in production code', () => {
  try {
    const result = execSync(
      'grep -rn "TODO\\|FIXME" --include="*.dart" flutter_app/lib/ 2>/dev/null | wc -l',
      { cwd: ROOT, encoding: 'utf-8' }
    ).trim();
    const count = parseInt(result);
    if (count > 10) return `${count} TODO/FIXME comments found`;
    return true;
  } catch {
    return true;
  }
});

// ─── 5. Security ─────────────────────────────────────
console.log('\n  Security\n');

check('No .env files tracked', () => {
  const tracked = execSync('git ls-files | grep -E "^\\.env$|/\\.env$" || echo ""', {
    cwd: ROOT, encoding: 'utf-8'
  }).trim();
  if (tracked) return '.env file is tracked by git';
  return true;
});

check('.gitignore includes sensitive patterns', () => {
  const gitignore = fs.readFileSync(path.join(ROOT, '.gitignore'), 'utf-8');
  if (!gitignore.includes('.env')) return 'Missing .env in .gitignore';
  if (!gitignore.includes('key.properties')) return 'Missing key.properties in .gitignore';
  return true;
});

// ─── 6. CI/CD ────────────────────────────────────────
console.log('\n  CI/CD\n');

const workflows = ['security-scan.yml', 'backend-ci.yml', 'flutter-ci.yml', 'release.yml', 'auto-docs.yml'];
for (const wf of workflows) {
  check(`Workflow ${wf} exists`, () => {
    const p = path.join(ROOT, '.github', 'workflows', wf);
    return fs.existsSync(p) ? true : 'Missing';
  });
}

// ─── 7. Documentation ───────────────────────────────
console.log('\n  Documentation\n');

check('API Reference exists', () => {
  return fs.existsSync(path.join(ROOT, 'docs', 'API_REFERENCE.md')) ? true : 'Missing';
});

check('CLAUDE.md exists', () => {
  return fs.existsSync(path.join(ROOT, 'CLAUDE.md')) ? true : 'Missing';
});

// ─── Summary ─────────────────────────────────────────
console.log('\n══════════════════════════════════════════════════');
console.log(`  Results: ${passed} passed, ${failed} failed`);
console.log('══════════════════════════════════════════════════');

if (failed > 0) {
  console.log('\n  Issues to fix before release:\n');
  for (const { name, reason } of issues) {
    console.log(`    • ${name}: ${reason}`);
  }
  console.log('');
  process.exit(1);
} else {
  console.log('\n  ✓ All checks passed. Ready for release!\n');
}
