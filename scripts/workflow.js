#!/usr/bin/env node
/**
 * MindScrolling Unified Workflow Manager
 *
 * Usage:
 *   node scripts/workflow.js <command>
 *
 * Commands:
 *   bootstrap    One-command new-developer setup
 *   dev          Start backend dev server
 *   test         Run all tests (backend syntax + tests)
 *   build:apk    Build Android APK
 *   build:aab    Build Android App Bundle
 *   build:all    Build APK + AAB + generate docs
 *   docs         Generate documentation
 *   release      Full release pipeline (test → build → docs → tag)
 *   status       Show project status
 *   doctor       Check dev environment health
 *   sprint       Sprint orchestration workflow (start/status/next/complete/fail/reset/report)
 *   qa           Run automated QA checks (--fix, --summary)
 */

const { execSync, spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const BACKEND = path.join(ROOT, 'backend');
const FLUTTER = path.join(ROOT, 'flutter_app');
const FLUTTER_BIN = 'C:\\flutter\\flutter\\bin\\flutter.bat';

const cmd = process.argv[2];

function run(command, cwd = ROOT) {
  console.log(`\n  → ${command}\n`);
  try {
    execSync(command, { cwd, stdio: 'inherit', timeout: 600000 });
    return true;
  } catch (e) {
    console.error(`  ✗ Failed: ${command}`);
    return false;
  }
}

function header(text) {
  console.log(`\n${'═'.repeat(50)}`);
  console.log(`  ${text}`);
  console.log(`${'═'.repeat(50)}`);
}

// ─── Commands ────────────────────────────────────────

const commands = {
  bootstrap() {
    header('New Developer Bootstrap');
    run('node scripts/bootstrap.js');
  },

  dev() {
    header('Starting Backend Dev Server');
    run('npm run dev', BACKEND);
  },

  test() {
    header('Running All Tests');
    let ok = true;

    console.log('\n📋 Backend Syntax Check...');
    const routeDir = path.join(BACKEND, 'src', 'routes');
    for (const f of fs.readdirSync(routeDir).filter(f => f.endsWith('.js'))) {
      if (!run(`node --check src/routes/${f}`, BACKEND)) ok = false;
    }

    console.log('\n📋 Backend Tests...');
    if (!run('npm test', BACKEND)) ok = false;

    console.log('\n📋 Flutter Analyze...');
    if (!run(`"${FLUTTER_BIN}" analyze --no-fatal-infos`, FLUTTER)) ok = false;

    if (ok) {
      console.log('\n  ✓ All tests passed!\n');
    } else {
      console.log('\n  ✗ Some tests failed.\n');
      process.exit(1);
    }
  },

  'build:apk'() {
    header('Building Android APK');
    run(`"${FLUTTER_BIN}" pub get`, FLUTTER);
    run(`"${FLUTTER_BIN}" build apk --release`, FLUTTER);

    const apk = path.join(FLUTTER, 'build', 'app', 'outputs', 'flutter-apk', 'app-release.apk');
    if (fs.existsSync(apk)) {
      const size = (fs.statSync(apk).size / 1024 / 1024).toFixed(1);
      console.log(`\n  ✓ APK ready: ${size}MB`);
      console.log(`    ${apk}\n`);
    }
  },

  'build:aab'() {
    header('Building Android App Bundle');
    run(`"${FLUTTER_BIN}" pub get`, FLUTTER);
    run(`"${FLUTTER_BIN}" build appbundle --release`, FLUTTER);

    const aab = path.join(FLUTTER, 'build', 'app', 'outputs', 'bundle', 'release', 'app-release.aab');
    if (fs.existsSync(aab)) {
      const size = (fs.statSync(aab).size / 1024 / 1024).toFixed(1);
      console.log(`\n  ✓ AAB ready: ${size}MB`);
      console.log(`    ${aab}\n`);
    }
  },

  'build:all'() {
    commands['build:apk']();
    commands['build:aab']();
    commands.docs();
  },

  docs() {
    header('Generating Documentation');
    run('node scripts/generate-docs.js');
  },

  release() {
    header('Full Release Pipeline');

    // 1. Test
    commands.test();

    // 2. Read current version
    const pubspec = fs.readFileSync(path.join(FLUTTER, 'pubspec.yaml'), 'utf-8');
    const vMatch = pubspec.match(/version:\s*(\S+)/);
    const version = vMatch ? vMatch[1] : 'unknown';
    console.log(`\n  Current version: ${version}`);

    // 3. Build
    commands['build:all']();

    // 4. Git tag
    const tag = `v${version.split('+')[0]}`;
    console.log(`\n  Creating tag: ${tag}`);
    run(`git tag -a ${tag} -m "Release ${tag}"`);
    console.log(`\n  Push with: git push origin ${tag}`);
    console.log(`  This will trigger the GitHub Release workflow.\n`);
  },

  status() {
    header('Project Status');
    run('node scripts/generate-docs.js');
    const status = fs.readFileSync(path.join(ROOT, 'docs', 'PROJECT_STATUS.md'), 'utf-8');
    console.log(status);
  },

  doctor() {
    header('Environment Health Check');
    const checks = [
      { name: 'Node.js', cmd: 'node --version' },
      { name: 'npm', cmd: 'npm --version' },
      { name: 'Git', cmd: 'git --version' },
      { name: 'Flutter', cmd: `"${FLUTTER_BIN}" --version` },
      { name: 'Dart', cmd: 'C:\\flutter\\flutter\\bin\\dart.bat --version' },
    ];

    for (const { name, cmd } of checks) {
      try {
        const out = execSync(cmd, { encoding: 'utf-8', timeout: 15000 }).trim().split('\n')[0];
        console.log(`  ✓ ${name}: ${out}`);
      } catch {
        console.log(`  ✗ ${name}: NOT FOUND`);
      }
    }

    // Check key files
    console.log('');
    const files = [
      'backend/package.json',
      'flutter_app/pubspec.yaml',
      'CLAUDE.md',
      '.github/workflows/backend-ci.yml',
      '.github/workflows/flutter-ci.yml',
      '.github/workflows/release.yml',
      '.github/workflows/ios-testflight.yml',
    ];
    for (const f of files) {
      const exists = fs.existsSync(path.join(ROOT, f));
      console.log(`  ${exists ? '✓' : '✗'} ${f}`);
    }
    console.log('');
  },

  bump() {
    const type = process.argv[3] || 'patch';
    header(`Version Bump (${type})`);
    run(`node scripts/bump-version.js ${type}`);
  },

  check() {
    header('Pre-Release Checklist');
    run('node scripts/pre-release-check.js');
  },

  health() {
    header('Backend Health Check');
    const mode = process.argv[3] || '';
    run(`node scripts/health-monitor.js ${mode}`);
  },

  rollback() {
    const target = process.argv[3] || '';
    run(`node scripts/rollback.js ${target}`);
  },

  migrations() {
    const mode = process.argv[3] || '--status';
    header('Database Migrations');
    run(`node scripts/run-migrations.js ${mode}`);
  },

  sentry() {
    run('node scripts/setup-sentry.js');
  },

  sprint() {
    // Pass all remaining args through to sprint-runner.js
    // e.g. workflow.js sprint start "my goal"
    //      workflow.js sprint status
    //      workflow.js sprint next
    const sprintArgs = process.argv.slice(3).join(' ');
    header('Sprint Runner');
    run(`node scripts/sprint-runner.js ${sprintArgs}`);
  },

  qa() {
    // Pass flags through: --fix, --summary
    const qaArgs = process.argv.slice(3).join(' ');
    header('QA Runner');
    run(`node scripts/qa-runner.js ${qaArgs}`);
  },

  'full-release'() {
    header('Full Release Pipeline');
    console.log('\n  Step 1/6: Pre-release checks...');
    run('node scripts/pre-release-check.js');

    console.log('\n  Step 2/6: Bump version...');
    const type = process.argv[3] || 'patch';
    run(`node scripts/bump-version.js ${type}`);

    console.log('\n  Step 3/6: Generate docs...');
    run('node scripts/generate-docs.js');

    console.log('\n  Step 4/6: Build AAB...');
    run(`"${FLUTTER_BIN}" pub get`, FLUTTER);
    run(`"${FLUTTER_BIN}" build appbundle --release`, FLUTTER);

    console.log('\n  Step 5/6: Build APK...');
    run(`"${FLUTTER_BIN}" build apk --release`, FLUTTER);

    console.log('\n  Step 6/6: Commit & tag...');
    const pubspec = fs.readFileSync(path.join(FLUTTER, 'pubspec.yaml'), 'utf-8');
    const vMatch = pubspec.match(/version:\s*(\S+)/);
    const version = vMatch ? vMatch[1].split('+')[0] : 'unknown';
    const tag = `v${version}`;

    run('git add -A');
    run(`git commit -m "release: ${tag}"`);
    run(`git tag -a ${tag} -m "Release ${tag}"`);

    console.log(`\n  ✓ Release ${tag} ready!`);
    console.log(`  Push with: git push origin main --tags`);
    console.log(`  This triggers: GitHub Release + Play Store deploy\n`);
  }
};

// ─── Run ─────────────────────────────────────────────

if (!cmd || !commands[cmd]) {
  console.log(`
  MindScrolling Workflow Manager

  Usage: node scripts/workflow.js <command>

  Onboarding:
    bootstrap      One-command new-developer setup (deps + .env + hooks + verify)

  Development:
    dev            Start backend dev server
    test           Run all tests
    doctor         Check environment health

  Build:
    build:apk      Build Android APK
    build:aab      Build Android App Bundle
    build:all      Build APK + AAB + docs
    docs           Generate documentation

  Release:
    bump [type]    Bump version (patch|minor|major)
    check          Run pre-release checklist
    release        Build + tag (manual push)
    full-release   Check → bump → docs → build → tag

  Operations:
    health [flag]  Backend health (--endpoints, --watch)
    rollback [h]   Rollback to commit (--last)
    migrations     Show DB migration status
    sentry         Check Sentry configuration
    status         Show project status

  Sprint Workflow:
    sprint start "<goal>"   Start a new sprint with the given goal
    sprint status           Show current sprint phase status
    sprint next             Print prompt for next pending phase
    sprint complete <phase> Mark a phase done (SCOPE/CONTRACT/BACKEND/MOBILE/QA/DOCS)
    sprint fail <phase>     Mark a phase failed
    sprint report           Print all handoff reports
    sprint reset            Clear sprint state

  QA:
    qa                      Run all automated QA checks
    qa --fix                Run checks + auto-fix (flutter format, etc.)
    qa --summary            Print last QA report summary
  `);
  process.exit(0);
}

commands[cmd]();
