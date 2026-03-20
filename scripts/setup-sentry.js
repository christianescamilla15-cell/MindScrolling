#!/usr/bin/env node
/**
 * Sentry configuration helper for MindScrolling
 *
 * Sentry is already integrated in both backend (app.js) and Flutter (main.dart).
 * This script checks the configuration status.
 *
 * Setup:
 *   1. Create project at https://sentry.io
 *   2. Get DSN from Project Settings → Client Keys
 *   3. Backend: Add SENTRY_DSN to backend/.env
 *   4. Flutter: Add SENTRY_DSN to flutter_app/.env or as build arg
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');

console.log('\n══════════════════════════════════════════════════');
console.log('  Sentry Error Tracking Status');
console.log('══════════════════════════════════════════════════\n');

// Check backend
const backendEnv = path.join(ROOT, 'backend', '.env');
if (fs.existsSync(backendEnv)) {
  const env = fs.readFileSync(backendEnv, 'utf-8');
  if (env.includes('SENTRY_DSN=') && !env.includes('SENTRY_DSN=\n') && !env.includes('SENTRY_DSN=""')) {
    console.log('  ✓ Backend: SENTRY_DSN configured');
  } else {
    console.log('  ✗ Backend: SENTRY_DSN not set in backend/.env');
  }
} else {
  console.log('  ✗ Backend: .env file not found');
}

// Check Flutter
const mainDart = path.join(ROOT, 'flutter_app', 'lib', 'main.dart');
if (fs.existsSync(mainDart)) {
  const content = fs.readFileSync(mainDart, 'utf-8');
  if (content.includes('SentryFlutter.init') || content.includes('Sentry.init')) {
    console.log('  ✓ Flutter: Sentry integration found in main.dart');
  } else {
    console.log('  ✗ Flutter: No Sentry initialization in main.dart');
  }
}

// Check Render env
console.log('\n  Render.com:');
console.log('    → Add SENTRY_DSN as environment variable in Render dashboard');
console.log('    → Settings → Environment → Add SENTRY_DSN\n');

console.log('  Sentry Dashboard: https://sentry.io');
console.log('  Docs: https://docs.sentry.io/platforms/node/\n');
