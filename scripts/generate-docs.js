#!/usr/bin/env node
/**
 * Auto-documentation generator for MindScrolling
 * Generates API_REFERENCE.md, CHANGELOG.md, and PROJECT_STATUS.md
 * Run: node scripts/generate-docs.js
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const ROOT = path.resolve(__dirname, '..');
const BACKEND = path.join(ROOT, 'backend', 'src');
const ROUTES_DIR = path.join(BACKEND, 'routes');
const DOCS_DIR = path.join(ROOT, 'docs');

// Ensure docs/ exists
if (!fs.existsSync(DOCS_DIR)) fs.mkdirSync(DOCS_DIR, { recursive: true });

// ─── 1. API REFERENCE ───────────────────────────────────────────────
function generateApiReference() {
  const routeFiles = fs.readdirSync(ROUTES_DIR).filter(f => f.endsWith('.js'));
  const routes = [];

  for (const file of routeFiles) {
    const content = fs.readFileSync(path.join(ROUTES_DIR, file), 'utf-8');
    const prefix = extractPrefix(content, file);
    const methods = extractRoutes(content);

    if (methods.length > 0) {
      routes.push({ file, prefix, methods });
    }
  }

  let md = `# MindScrolling API Reference\n\n`;
  md += `> Auto-generated on ${new Date().toISOString().split('T')[0]}\n\n`;
  md += `Base URL: \`https://mindscrolling.onrender.com/api\`\n\n`;
  md += `## Endpoints\n\n`;

  for (const { file, prefix, methods } of routes) {
    const section = file.replace('.js', '').replace(/-/g, ' ');
    md += `### ${capitalize(section)} (\`${prefix}\`)\n\n`;
    md += `| Method | Path | Description |\n`;
    md += `|--------|------|-------------|\n`;

    for (const { method, path: routePath, description } of methods) {
      const fullPath = `${prefix}${routePath === '/' ? '' : routePath}`;
      md += `| \`${method}\` | \`${fullPath}\` | ${description} |\n`;
    }
    md += `\n`;
  }

  // Auth section
  md += `## Authentication\n\n`;
  md += `All endpoints require \`x-device-id\` header (UUID v4).\n`;
  md += `Premium endpoints additionally check entitlement status.\n\n`;

  // Rate limits
  md += `## Rate Limits\n\n`;
  md += `| Endpoint | Limit |\n`;
  md += `|----------|-------|\n`;
  md += `| POST /api/swipes | 120/min |\n`;
  md += `| GET /api/quotes/feed | 60/min |\n`;
  md += `| POST /api/insights/weekly | 10/min |\n`;
  md += `| All others | 100/min |\n`;

  fs.writeFileSync(path.join(DOCS_DIR, 'API_REFERENCE.md'), md);
  console.log('  ✓ docs/API_REFERENCE.md');
}

function extractPrefix(content, file) {
  const match = content.match(/prefix:\s*['"`]([^'"`]+)['"`]/);
  if (match) return `/api${match[1]}`;
  return `/api/${file.replace('.js', '')}`;
}

function extractRoutes(content) {
  const routes = [];
  const regex = /fastify\.(get|post|put|delete|patch)\s*\(\s*['"`]([^'"`]+)['"`]/gi;
  let match;

  while ((match = regex.exec(content)) !== null) {
    const method = match[1].toUpperCase();
    const routePath = match[2];

    // Try to find a comment above or inline description
    const lineIndex = content.substring(0, match.index).lastIndexOf('\n');
    const prevLines = content.substring(Math.max(0, lineIndex - 200), match.index);
    const commentMatch = prevLines.match(/\/\/\s*(.+)$/m) || prevLines.match(/\/\*\*?\s*(.+?)\s*\*\//);
    const description = commentMatch ? commentMatch[1].trim() : inferDescription(method, routePath);

    routes.push({ method, path: routePath, description });
  }
  return routes;
}

function inferDescription(method, routePath) {
  const resource = routePath.replace(/^\//, '').replace(/:[\w]+/g, '{id}') || 'resource';
  switch (method) {
    case 'GET': return `Retrieve ${resource}`;
    case 'POST': return `Create/update ${resource}`;
    case 'PUT': return `Update ${resource}`;
    case 'DELETE': return `Delete ${resource}`;
    case 'PATCH': return `Partial update ${resource}`;
    default: return `${method} ${resource}`;
  }
}

// ─── 2. CHANGELOG ────────────────────────────────────────────────────
function generateChangelog() {
  let log;
  try {
    log = execSync('git log --oneline --no-merges -50', { cwd: ROOT, encoding: 'utf-8' });
  } catch {
    console.log('  ⚠ Could not read git log');
    return;
  }

  const lines = log.trim().split('\n');
  const sections = { feat: [], fix: [], refactor: [], docs: [], chore: [], other: [] };

  for (const line of lines) {
    const match = line.match(/^([a-f0-9]+)\s+(feat|fix|refactor|docs|chore|ci|test)?:?\s*(.+)$/i);
    if (match) {
      const [, hash, type, msg] = match;
      const key = (type || 'other').toLowerCase();
      const section = sections[key] || sections.other;
      section.push({ hash: hash.substring(0, 7), msg: msg.trim() });
    } else {
      const [hash, ...rest] = line.split(' ');
      sections.other.push({ hash: hash.substring(0, 7), msg: rest.join(' ') });
    }
  }

  let md = `# Changelog\n\n`;
  md += `> Auto-generated on ${new Date().toISOString().split('T')[0]}\n\n`;

  const labels = {
    feat: 'Features',
    fix: 'Bug Fixes',
    refactor: 'Refactoring',
    docs: 'Documentation',
    chore: 'Chores',
    other: 'Other Changes'
  };

  for (const [key, label] of Object.entries(labels)) {
    if (sections[key] && sections[key].length > 0) {
      md += `## ${label}\n\n`;
      for (const { hash, msg } of sections[key]) {
        md += `- \`${hash}\` ${msg}\n`;
      }
      md += `\n`;
    }
  }

  fs.writeFileSync(path.join(DOCS_DIR, 'CHANGELOG.md'), md);
  console.log('  ✓ docs/CHANGELOG.md');
}

// ─── 3. PROJECT STATUS ──────────────────────────────────────────────
function generateProjectStatus() {
  // Count files
  const countFiles = (dir, ext) => {
    if (!fs.existsSync(dir)) return 0;
    let count = 0;
    const walk = (d) => {
      for (const f of fs.readdirSync(d, { withFileTypes: true })) {
        if (f.isDirectory() && !f.name.startsWith('.') && f.name !== 'node_modules' && f.name !== 'build') {
          walk(path.join(d, f.name));
        } else if (f.name.endsWith(ext)) {
          count++;
        }
      }
    };
    walk(dir);
    return count;
  };

  const backendFiles = countFiles(path.join(ROOT, 'backend', 'src'), '.js');
  const dartFiles = countFiles(path.join(ROOT, 'flutter_app', 'lib'), '.dart');
  const routeFiles = fs.readdirSync(ROUTES_DIR).filter(f => f.endsWith('.js')).length;
  const migrationDir = path.join(ROOT, 'backend', 'src', 'db', 'migrations');
  const migrations = fs.existsSync(migrationDir)
    ? fs.readdirSync(migrationDir).filter(f => f.endsWith('.sql')).length
    : 0;

  // Get version from pubspec
  let version = 'unknown';
  try {
    const pubspec = fs.readFileSync(path.join(ROOT, 'flutter_app', 'pubspec.yaml'), 'utf-8');
    const vMatch = pubspec.match(/version:\s*(.+)/);
    if (vMatch) version = vMatch[1].trim();
  } catch {}

  // Get git stats
  let totalCommits = 0;
  let lastCommit = 'unknown';
  try {
    totalCommits = parseInt(execSync('git rev-list --count HEAD', { cwd: ROOT, encoding: 'utf-8' }).trim());
    lastCommit = execSync('git log -1 --format="%h %s"', { cwd: ROOT, encoding: 'utf-8' }).trim();
  } catch {}

  let md = `# MindScrolling — Project Status\n\n`;
  md += `> Auto-generated on ${new Date().toISOString().split('T')[0]}\n\n`;
  md += `## Overview\n\n`;
  md += `| Metric | Value |\n`;
  md += `|--------|-------|\n`;
  md += `| App Version | \`${version}\` |\n`;
  md += `| Total Commits | ${totalCommits} |\n`;
  md += `| Last Commit | \`${lastCommit}\` |\n`;
  md += `| Backend Files (JS) | ${backendFiles} |\n`;
  md += `| Flutter Files (Dart) | ${dartFiles} |\n`;
  md += `| API Route Files | ${routeFiles} |\n`;
  md += `| DB Migrations | ${migrations} |\n\n`;

  md += `## Architecture\n\n`;
  md += `- **Backend**: Fastify + Supabase (hosted on Render)\n`;
  md += `- **Mobile**: Flutter (Android, Play Store closed beta)\n`;
  md += `- **Database**: PostgreSQL via Supabase\n`;
  md += `- **AI**: Claude API for weekly insights\n`;
  md += `- **Payments**: RevenueCat + Google Play Billing\n\n`;

  md += `## API Endpoints: ${routeFiles} route files\n\n`;
  md += `See [API_REFERENCE.md](API_REFERENCE.md) for full details.\n\n`;

  md += `## CI/CD Pipelines\n\n`;
  md += `| Workflow | Trigger | Purpose |\n`;
  md += `|---------|---------|--------|\n`;
  md += `| security-scan | push to main | Secret detection, dependency audit |\n`;
  md += `| backend-ci | push to backend/ | Syntax check, tests |\n`;
  md += `| flutter-ci | push to flutter_app/ | Analyze, build APK |\n`;
  md += `| release | git tag v* | Build AAB/APK, GitHub Release |\n`;

  fs.writeFileSync(path.join(DOCS_DIR, 'PROJECT_STATUS.md'), md);
  console.log('  ✓ docs/PROJECT_STATUS.md');
}

// ─── HELPERS ─────────────────────────────────────────────────────────
function capitalize(s) {
  return s.split(' ').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
}

// ─── RUN ─────────────────────────────────────────────────────────────
console.log('Generating docs...\n');
generateApiReference();
generateChangelog();
generateProjectStatus();
console.log('\nDone.');
