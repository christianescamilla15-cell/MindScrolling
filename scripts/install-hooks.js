#!/usr/bin/env node
/**
 * Installs git hooks for MindScrolling
 * Run once: node scripts/install-hooks.js
 */

const fs = require('fs');
const path = require('path');

const HOOKS_DIR = path.resolve(__dirname, '..', '.git', 'hooks');

const preCommitHook = `#!/bin/sh
# Auto-generate docs before commit
node scripts/generate-docs.js 2>/dev/null
git add docs/ 2>/dev/null
`;

const hookPath = path.join(HOOKS_DIR, 'pre-commit');

// Don't overwrite existing hook — append
if (fs.existsSync(hookPath)) {
  const existing = fs.readFileSync(hookPath, 'utf-8');
  if (existing.includes('generate-docs')) {
    console.log('Hook already installed.');
    process.exit(0);
  }
  fs.appendFileSync(hookPath, '\n' + preCommitHook);
} else {
  fs.writeFileSync(hookPath, preCommitHook);
}

// Make executable (Unix)
try {
  fs.chmodSync(hookPath, '755');
} catch {}

console.log('✓ Pre-commit hook installed. Docs will auto-generate on each commit.');
