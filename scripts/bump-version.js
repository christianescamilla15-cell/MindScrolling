#!/usr/bin/env node
/**
 * Auto version bump for MindScrolling
 *
 * Usage:
 *   node scripts/bump-version.js patch    # 1.2.0 → 1.2.1
 *   node scripts/bump-version.js minor    # 1.2.0 → 1.3.0
 *   node scripts/bump-version.js major    # 1.2.0 → 2.0.0
 *   node scripts/bump-version.js          # defaults to patch
 */

const fs = require('fs');
const path = require('path');

const PUBSPEC = path.resolve(__dirname, '..', 'flutter_app', 'pubspec.yaml');
const type = process.argv[2] || 'patch';

const content = fs.readFileSync(PUBSPEC, 'utf-8');
const match = content.match(/version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)/);

if (!match) {
  console.error('Could not find version in pubspec.yaml');
  process.exit(1);
}

let [, major, minor, patch, build] = match.map(Number);
const oldVersion = `${major}.${minor}.${patch}+${build}`;

switch (type) {
  case 'major':
    major++;
    minor = 0;
    patch = 0;
    break;
  case 'minor':
    minor++;
    patch = 0;
    break;
  case 'patch':
  default:
    patch++;
    break;
}
build++;

const newVersion = `${major}.${minor}.${patch}+${build}`;
const updated = content.replace(`version: ${oldVersion}`, `version: ${newVersion}`);
fs.writeFileSync(PUBSPEC, updated);

console.log(`  Version bumped: ${oldVersion} → ${newVersion}`);
console.log(`  Updated: flutter_app/pubspec.yaml`);
