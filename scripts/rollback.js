#!/usr/bin/env node
/**
 * Rollback manager for MindScrolling
 *
 * Usage:
 *   node scripts/rollback.js                 # Show recent deployable commits
 *   node scripts/rollback.js <commit-hash>   # Rollback to specific commit
 *   node scripts/rollback.js --last          # Rollback to previous commit
 */

const { execSync } = require('child_process');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const target = process.argv[2];

function run(cmd) {
  return execSync(cmd, { cwd: ROOT, encoding: 'utf-8' }).trim();
}

function showHistory() {
  console.log('\n══════════════════════════════════════════════════');
  console.log('  MindScrolling Rollback Manager');
  console.log('══════════════════════════════════════════════════\n');

  const current = run('git rev-parse --short HEAD');
  const branch = run('git branch --show-current');
  console.log(`  Current: ${current} on ${branch}\n`);

  console.log('  Recent commits (rollback targets):\n');
  const log = run('git log --oneline -15');
  const lines = log.split('\n');
  lines.forEach((line, i) => {
    const marker = i === 0 ? ' ← current' : '';
    console.log(`    ${line}${marker}`);
  });

  console.log('\n  Usage:');
  console.log('    node scripts/rollback.js <hash>    # Rollback to commit');
  console.log('    node scripts/rollback.js --last    # Rollback 1 commit\n');
}

function rollback(commitHash) {
  const current = run('git rev-parse --short HEAD');

  console.log(`\n  Rolling back: ${current} → ${commitHash}\n`);

  // Create a rollback branch for safety
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);
  const backupBranch = `backup/pre-rollback-${timestamp}`;

  console.log(`  Creating backup branch: ${backupBranch}`);
  run(`git branch ${backupBranch}`);

  // Revert by creating a new commit that undoes changes
  console.log(`  Creating revert commit...`);
  try {
    run(`git revert --no-commit ${commitHash}..HEAD`);
    run(`git commit -m "rollback: revert to ${commitHash}"`);
    console.log(`\n  ✓ Rollback complete.`);
    console.log(`  ✓ Backup saved at branch: ${backupBranch}`);
    console.log(`\n  To deploy: git push origin main`);
    console.log(`  To undo:   git revert HEAD\n`);
  } catch (e) {
    console.log(`\n  ✗ Rollback failed — conflicts detected.`);
    console.log(`  Resolve manually or run: git revert --abort\n`);
    try { run('git revert --abort'); } catch {}
  }
}

// ─── Run ─────────────────────────────────────────────
if (!target) {
  showHistory();
} else if (target === '--last') {
  const prev = run('git rev-parse --short HEAD~1');
  rollback(prev);
} else {
  rollback(target);
}
