#!/usr/bin/env node
/**
 * MindScrolling Sprint Orchestration Runner
 *
 * Manages the multi-agent sprint workflow. Does NOT call Claude directly —
 * it generates structured prompt files and tracks phase state so each agent
 * can be run in sequence by a human or CI pipeline.
 *
 * Usage:
 *   node scripts/sprint-runner.js start "<sprint goal>"
 *   node scripts/sprint-runner.js status
 *   node scripts/sprint-runner.js next
 *   node scripts/sprint-runner.js complete <phase>   # mark a phase done manually
 *   node scripts/sprint-runner.js fail <phase>       # mark a phase failed
 *   node scripts/sprint-runner.js reset
 *   node scripts/sprint-runner.js report             # print all handoff reports
 */

'use strict';

const fs   = require('fs');
const path = require('path');

const ROOT          = path.resolve(__dirname, '..');
const STATE_FILE    = path.join(ROOT, '.sprint-state.json');
const PROMPTS_DIR   = path.join(ROOT, '.sprint-prompts');
const REPORTS_DIR   = path.join(ROOT, '.sprint-reports');

// ─── Phase definitions ────────────────────────────────────────────────────────

const PHASES = [
  {
    id:    'SCOPE',
    agent: 'product-owner',
    title: 'Sprint Scope Definition',
    description: 'Defines user stories, acceptance criteria, and out-of-scope boundaries.',
    dependsOn: [],
    outputs: ['scope document', 'acceptance criteria list', 'out-of-scope list'],
  },
  {
    id:    'CONTRACT',
    agent: 'api-architect',
    title: 'API Contract Design',
    description: 'Designs all new/changed API endpoints, DB schema changes, and migration SQL.',
    dependsOn: ['SCOPE'],
    outputs: ['endpoint contracts (method, path, request, response schemas)', 'migration SQL stubs', 'Supabase RPC signatures'],
  },
  {
    id:    'BACKEND',
    agent: 'backend-implementer',
    title: 'Backend Implementation',
    description: 'Implements Fastify routes, Supabase queries, and service logic per the contract.',
    dependsOn: ['CONTRACT'],
    outputs: ['route files', 'service files', 'migration files', 'npm test passing'],
  },
  {
    id:    'MOBILE',
    agent: 'flutter-mobile-engineer',
    title: 'Flutter Mobile Implementation',
    description: 'Implements Flutter screens, providers, models, and API client calls per the contract.',
    dependsOn: ['CONTRACT'],
    outputs: ['screen files', 'provider files', 'model files', 'flutter analyze clean'],
  },
  {
    id:    'QA',
    agent: 'qa-reviewer',
    title: 'QA Audit',
    description: 'Runs automated QA checks and performs manual audit against acceptance criteria.',
    dependsOn: ['BACKEND', 'MOBILE'],
    outputs: ['QA report', 'bug list by severity', 'pass/fail verdict'],
  },
  {
    id:    'DOCS',
    agent: 'documentation-writer',
    title: 'Documentation Update',
    description: 'Updates API reference, CHANGELOG, and any architecture docs impacted by the sprint.',
    dependsOn: ['QA'],
    outputs: ['updated API_REFERENCE.md', 'CHANGELOG entry', 'updated PROJECT_STATUS.md'],
  },
];

// ─── State helpers ────────────────────────────────────────────────────────────

function loadState() {
  if (!fs.existsSync(STATE_FILE)) return null;
  return JSON.parse(fs.readFileSync(STATE_FILE, 'utf-8'));
}

function saveState(state) {
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
}

function ensureDirs() {
  [PROMPTS_DIR, REPORTS_DIR].forEach(d => {
    if (!fs.existsSync(d)) fs.mkdirSync(d, { recursive: true });
  });
}

function now() {
  return new Date().toISOString();
}

// ─── Prompt generation ────────────────────────────────────────────────────────

function buildPrompt(phase, state) {
  const completedPhases = state.phases
    .filter(p => p.status === 'done')
    .map(p => p.id);

  // Gather handoff context from completed dependency phases
  const handoffContext = phase.dependsOn
    .filter(dep => completedPhases.includes(dep))
    .map(dep => {
      const reportPath = path.join(REPORTS_DIR, `${dep}.md`);
      if (fs.existsSync(reportPath)) {
        const content = fs.readFileSync(reportPath, 'utf-8');
        return `### Handoff from ${dep}\n\n${content}`;
      }
      return `### Handoff from ${dep}\n\n(No report found — phase may not have generated one yet.)`;
    })
    .join('\n\n---\n\n');

  const lines = [
    `# ${phase.title}`,
    ``,
    `**Agent:** ${phase.agent}`,
    `**Sprint:** ${state.goal}`,
    `**Sprint ID:** ${state.id}`,
    `**Phase:** ${phase.id}`,
    `**Started:** ${now()}`,
    ``,
    `---`,
    ``,
    `## Your Role`,
    ``,
    `You are the **${phase.agent}** for MindScrolling.`,
    ``,
    `## Sprint Goal`,
    ``,
    state.goal,
    ``,
    `## Phase Objective`,
    ``,
    phase.description,
    ``,
    `## Expected Outputs`,
    ``,
    phase.outputs.map(o => `- ${o}`).join('\n'),
    ``,
    `## Project Context`,
    ``,
    `- Backend: Fastify (Node.js 20) at \`backend/src/\``,
    `- Routes: one file per resource in \`backend/src/routes/\``,
    `- Shared utils: \`backend/src/utils/validation.js\` (UUID_RE, authorSlug, normalizeLang)`,
    `- Every endpoint requires \`x-device-id\` header validation`,
    `- Database: Supabase via \`request.server.supabase\``,
    `- Error responses: \`{ error: 'message' }\` with correct HTTP status`,
    `- Flutter app: \`flutter_app/lib/\` — Riverpod + GoRouter`,
    `- API client: \`core/services/api_client.dart\``,
    `- Models: \`data/models/\`, Providers: \`data/providers/\`, Screens: \`features/<feature>/\``,
    ``,
  ];

  if (handoffContext) {
    lines.push(`## Inputs from Previous Phases`, ``);
    lines.push(handoffContext, ``);
  }

  if (phase.dependsOn.length > 0) {
    const missing = phase.dependsOn.filter(dep => !completedPhases.includes(dep));
    if (missing.length > 0) {
      lines.push(
        `## WARNING`,
        ``,
        `The following dependency phases are NOT yet marked done:`,
        missing.map(d => `- ${d}`).join('\n'),
        ``,
        `You should confirm their outputs before proceeding.`,
        ``,
      );
    }
  }

  // Phase-specific instructions
  lines.push(`## Instructions`, ``);

  switch (phase.id) {
    case 'SCOPE':
      lines.push(
        `1. Read the sprint goal above carefully.`,
        `2. Break it down into concrete user stories (As a user, I want...).`,
        `3. Define clear acceptance criteria for each story.`,
        `4. List explicitly what is OUT OF SCOPE for this sprint.`,
        `5. Identify any risks or dependencies.`,
        ``,
        `Output your work as a Handoff Report (see format below) and write it to:`,
        `\`.sprint-reports/SCOPE.md\``,
      );
      break;

    case 'CONTRACT':
      lines.push(
        `1. Review the SCOPE handoff above.`,
        `2. Design every new or changed API endpoint:`,
        `   - Method, path, request body/params, response schema`,
        `   - Required headers (always x-device-id)`,
        `   - Error cases and HTTP status codes`,
        `3. Design any DB schema changes as migration SQL stubs.`,
        `4. Specify any new Supabase RPC signatures.`,
        `5. Do NOT implement — design only.`,
        ``,
        `Output your work as a Handoff Report and write it to:`,
        `\`.sprint-reports/CONTRACT.md\``,
      );
      break;

    case 'BACKEND':
      lines.push(
        `1. Review the CONTRACT handoff above.`,
        `2. Implement each endpoint exactly as specified.`,
        `3. Follow all coding standards from CLAUDE.md:`,
        `   - No fire-and-forget async`,
        `   - Use .maybeSingle() for queries that may return 0 rows`,
        `   - Validate UUIDs with UUID_RE before DB queries`,
        `   - Use normalizeLang() for language codes`,
        `4. Write or update migration SQL files in order (001, 002, 003...).`,
        `5. Ensure \`npm test\` passes in \`backend/\`.`,
        `6. Run \`node --check\` on every route/service file you touch.`,
        ``,
        `Output your Handoff Report to: \`.sprint-reports/BACKEND.md\``,
        `Include: files changed, endpoints added/modified, migration files, test results.`,
      );
      break;

    case 'MOBILE':
      lines.push(
        `1. Review the CONTRACT handoff above.`,
        `2. Implement Flutter screens, providers, and models per the contract.`,
        `3. Follow all Flutter rules from CLAUDE.md:`,
        `   - Check \`mounted\` before setState/navigation in async callbacks`,
        `   - All user-facing strings must use AppLocalizations`,
        `   - Use Riverpod providers — no direct API calls from widgets`,
        `4. Add any new API methods to ApiClient in \`core/services/api_client.dart\`.`,
        `5. Ensure \`flutter analyze --no-fatal-infos\` returns no errors.`,
        ``,
        `Output your Handoff Report to: \`.sprint-reports/MOBILE.md\``,
        `Include: screens added/changed, providers added/changed, API client methods added.`,
      );
      break;

    case 'QA':
      lines.push(
        `1. Run the automated QA suite: \`node scripts/qa-runner.js\``,
        `2. Review the QA report output.`,
        `3. Manually verify each acceptance criterion from the SCOPE phase.`,
        `4. Check all files changed in BACKEND and MOBILE handoffs.`,
        `5. Test edge cases: missing headers, invalid UUIDs, empty results, language variants.`,
        `6. Classify any bugs found: CRITICAL / HIGH / MEDIUM / LOW.`,
        `7. CRITICAL and HIGH bugs must be fixed before declaring QA passed.`,
        ``,
        `Output your Handoff Report to: \`.sprint-reports/QA.md\``,
        `Include: automated check results, manual findings, bug list, final verdict (PASS/FAIL).`,
      );
      break;

    case 'DOCS':
      lines.push(
        `1. Run \`node scripts/generate-docs.js\` to refresh auto-generated docs.`,
        `2. Update \`docs/API_REFERENCE.md\` for every new/changed endpoint.`,
        `3. Add a CHANGELOG entry for this sprint (version, date, changes).`,
        `4. Update \`docs/PROJECT_STATUS.md\` to reflect current sprint completion.`,
        `5. Review the SCOPE handoff to ensure all features are documented.`,
        ``,
        `Output your Handoff Report to: \`.sprint-reports/DOCS.md\``,
        `Include: files updated, endpoints documented, CHANGELOG entry text.`,
      );
      break;
  }

  lines.push(
    ``,
    `---`,
    ``,
    `## Handoff Report Format`,
    ``,
    `When you are done, write a file to \`.sprint-reports/${phase.id}.md\` with this structure:`,
    ``,
    `\`\`\``,
    `# ${phase.id} Handoff Report`,
    `Sprint: ${state.goal}`,
    `Agent: ${phase.agent}`,
    `Completed: <ISO timestamp>`,
    `Status: DONE | FAILED`,
    ``,
    `## Summary`,
    `[1-3 sentences describing what was done]`,
    ``,
    `## Outputs`,
    `[Bullet list of concrete deliverables with file paths where applicable]`,
    ``,
    `## Notes for Next Phase`,
    `[Anything the next agent needs to know: gotchas, decisions made, deferred items]`,
    ``,
    `## Issues / Blockers`,
    `[Any problems encountered — none if clean]`,
    `\`\`\``,
    ``,
    `After writing the report, mark this phase complete:`,
    `\`\`\``,
    `node scripts/sprint-runner.js complete ${phase.id}`,
    `\`\`\``,
  );

  return lines.join('\n');
}

// ─── Commands ─────────────────────────────────────────────────────────────────

function cmdStart(goal) {
  if (!goal || goal.trim().length < 5) {
    console.error('  Error: Please provide a sprint goal (at least 5 characters).');
    console.error('  Usage: node scripts/sprint-runner.js start "<goal>"');
    process.exit(1);
  }

  const existing = loadState();
  if (existing && existing.status === 'running') {
    console.error(`  Error: A sprint is already running: "${existing.goal}"`);
    console.error('  Run "reset" first or complete the existing sprint.');
    process.exit(1);
  }

  ensureDirs();

  const sprintId = `sprint-${Date.now()}`;
  const state = {
    id: sprintId,
    goal: goal.trim(),
    startedAt: now(),
    status: 'running',
    phases: PHASES.map(p => ({
      id: p.id,
      status: 'pending',
      startedAt: null,
      completedAt: null,
    })),
  };

  saveState(state);

  // Generate all prompt files up front
  for (const phase of PHASES) {
    const prompt = buildPrompt(phase, state);
    const promptPath = path.join(PROMPTS_DIR, `${phase.id}.md`);
    fs.writeFileSync(promptPath, prompt);
  }

  console.log(`\n  Sprint started: ${sprintId}`);
  console.log(`  Goal: ${goal.trim()}`);
  console.log(`\n  Prompt files generated in .sprint-prompts/:`);
  for (const p of PHASES) {
    console.log(`    .sprint-prompts/${p.id}.md  →  feed to ${p.agent}`);
  }
  console.log(`\n  Run "node scripts/sprint-runner.js next" to begin the first phase.`);
  console.log('');
}

function cmdStatus() {
  const state = loadState();
  if (!state) {
    console.log('\n  No sprint in progress. Run: node scripts/sprint-runner.js start "<goal>"\n');
    return;
  }

  const STATUS_ICON = {
    pending: '  [ ]',
    running: '  [~]',
    done:    '  [x]',
    failed:  '  [!]',
  };

  console.log(`\n  Sprint: ${state.id}`);
  console.log(`  Goal:   ${state.goal}`);
  console.log(`  Status: ${state.status}`);
  console.log(`  Since:  ${state.startedAt}`);
  console.log('');
  console.log('  Phases:');
  console.log('');

  for (const phaseState of state.phases) {
    const def = PHASES.find(p => p.id === phaseState.id);
    const icon = STATUS_ICON[phaseState.status] || '  [?]';
    const agentLabel = `(${def.agent})`;
    let line = `${icon} ${phaseState.id.padEnd(10)} ${def.title.padEnd(32)} ${agentLabel}`;
    if (phaseState.completedAt) {
      line += `  done ${phaseState.completedAt.slice(0, 10)}`;
    }
    console.log(line);
  }

  const next = state.phases.find(p => p.status === 'pending');
  if (next) {
    const def = PHASES.find(p => p.id === next.id);
    console.log('');
    console.log(`  Next phase: ${next.id} — ${def.title}`);
    console.log(`  Prompt:     .sprint-prompts/${next.id}.md`);
    console.log(`  Run:        node scripts/sprint-runner.js next`);
  } else if (state.phases.every(p => p.status === 'done')) {
    console.log('\n  All phases complete. Sprint finished.');
  }

  console.log('');
}

function cmdNext() {
  const state = loadState();
  if (!state) {
    console.error('\n  No sprint in progress.\n');
    process.exit(1);
  }

  const nextPhase = state.phases.find(p => p.status === 'pending');
  if (!nextPhase) {
    if (state.phases.every(p => p.status === 'done')) {
      console.log('\n  All phases complete. Sprint is finished.\n');
    } else {
      const failed = state.phases.filter(p => p.status === 'failed');
      console.log(`\n  No pending phases. ${failed.length} phase(s) failed: ${failed.map(p => p.id).join(', ')}\n`);
    }
    return;
  }

  const def = PHASES.find(p => p.id === nextPhase.id);

  // Check dependencies
  const unmetDeps = def.dependsOn.filter(dep => {
    const depState = state.phases.find(p => p.id === dep);
    return depState.status !== 'done';
  });

  if (unmetDeps.length > 0) {
    console.error(`\n  Cannot start ${nextPhase.id}: dependencies not met: ${unmetDeps.join(', ')}`);
    console.error('  Complete or manually mark those phases first.\n');
    process.exit(1);
  }

  // Regenerate the prompt now (to pick up completed reports from deps)
  ensureDirs();
  const prompt = buildPrompt(def, state);
  const promptPath = path.join(PROMPTS_DIR, `${def.id}.md`);
  fs.writeFileSync(promptPath, prompt);

  // Mark as running
  nextPhase.status = 'running';
  nextPhase.startedAt = now();
  saveState(state);

  console.log(`\n  Phase: ${def.id} — ${def.title}`);
  console.log(`  Agent: ${def.agent}`);
  console.log('');
  console.log(`  Prompt file (updated with latest handoff context):`);
  console.log(`    ${promptPath}`);
  console.log('');
  console.log('  Feed this prompt to Claude Code with:');
  console.log(`    claude < .sprint-prompts/${def.id}.md`);
  console.log('');
  console.log('  When done, mark complete:');
  console.log(`    node scripts/sprint-runner.js complete ${def.id}`);
  console.log('');
}

function cmdComplete(phaseId) {
  if (!phaseId) {
    console.error('  Usage: node scripts/sprint-runner.js complete <PHASE_ID>');
    process.exit(1);
  }

  const state = loadState();
  if (!state) {
    console.error('  No sprint in progress.');
    process.exit(1);
  }

  const phaseState = state.phases.find(p => p.id === phaseId.toUpperCase());
  if (!phaseState) {
    console.error(`  Unknown phase: ${phaseId}. Valid: ${PHASES.map(p => p.id).join(', ')}`);
    process.exit(1);
  }

  const reportPath = path.join(REPORTS_DIR, `${phaseState.id}.md`);
  if (!fs.existsSync(reportPath)) {
    console.log(`  Warning: No handoff report found at .sprint-reports/${phaseState.id}.md`);
    console.log('  Consider writing one before marking done.');
  }

  phaseState.status = 'done';
  phaseState.completedAt = now();

  // Check if all done
  if (state.phases.every(p => p.status === 'done')) {
    state.status = 'completed';
  }

  saveState(state);

  console.log(`\n  Phase ${phaseState.id} marked as DONE.`);

  if (state.status === 'completed') {
    console.log('  All phases complete. Sprint finished!');
    printSprintSummary(state);
  } else {
    const next = state.phases.find(p => p.status === 'pending');
    if (next) {
      console.log(`  Next: ${next.id} — run "node scripts/sprint-runner.js next"`);
    }
  }
  console.log('');
}

function cmdFail(phaseId) {
  if (!phaseId) {
    console.error('  Usage: node scripts/sprint-runner.js fail <PHASE_ID>');
    process.exit(1);
  }

  const state = loadState();
  if (!state) {
    console.error('  No sprint in progress.');
    process.exit(1);
  }

  const phaseState = state.phases.find(p => p.id === phaseId.toUpperCase());
  if (!phaseState) {
    console.error(`  Unknown phase: ${phaseId}`);
    process.exit(1);
  }

  phaseState.status = 'failed';
  phaseState.completedAt = now();
  state.status = 'blocked';
  saveState(state);

  console.log(`\n  Phase ${phaseState.id} marked as FAILED.`);
  console.log('  Fix the issue and re-run: node scripts/sprint-runner.js next');
  console.log('  Or reset the phase: set status back to "pending" in .sprint-state.json');
  console.log('');
}

function cmdReset() {
  if (fs.existsSync(STATE_FILE)) {
    fs.unlinkSync(STATE_FILE);
    console.log('\n  Sprint state cleared.');
  } else {
    console.log('\n  No sprint state to clear.');
  }

  // Clean prompt files
  if (fs.existsSync(PROMPTS_DIR)) {
    for (const f of fs.readdirSync(PROMPTS_DIR)) {
      fs.unlinkSync(path.join(PROMPTS_DIR, f));
    }
    console.log('  Sprint prompts cleared.');
  }

  console.log('  Run "node scripts/sprint-runner.js start <goal>" to start a new sprint.\n');
}

function cmdReport() {
  const state = loadState();
  if (!state) {
    console.log('\n  No sprint in progress.\n');
    return;
  }

  console.log(`\n  Sprint Reports — ${state.goal}`);
  console.log('  ' + '='.repeat(60));

  for (const phase of PHASES) {
    const reportPath = path.join(REPORTS_DIR, `${phase.id}.md`);
    const phaseState = state.phases.find(p => p.id === phase.id);
    console.log(`\n  [${phaseState.status.toUpperCase()}] ${phase.id} — ${phase.title}`);

    if (fs.existsSync(reportPath)) {
      const content = fs.readFileSync(reportPath, 'utf-8');
      // Print with indent
      console.log(content.split('\n').map(l => '    ' + l).join('\n'));
    } else {
      console.log('    (no report written yet)');
    }
  }
  console.log('');
}

function printSprintSummary(state) {
  console.log('\n  Sprint Summary');
  console.log('  ' + '='.repeat(50));
  console.log(`  ID:      ${state.id}`);
  console.log(`  Goal:    ${state.goal}`);
  console.log(`  Started: ${state.startedAt}`);
  console.log(`  Ended:   ${now()}`);
  console.log('');
  console.log('  Reports:');
  for (const p of PHASES) {
    const rPath = path.join(REPORTS_DIR, `${p.id}.md`);
    const exists = fs.existsSync(rPath) ? 'written' : 'missing';
    console.log(`    .sprint-reports/${p.id}.md  [${exists}]`);
  }
}

// ─── Help ─────────────────────────────────────────────────────────────────────

function printHelp() {
  console.log(`
  MindScrolling Sprint Runner

  Usage: node scripts/sprint-runner.js <command>

  Commands:
    start "<goal>"     Start a new sprint with the given goal
    status             Show current sprint phase status
    next               Print prompt for next pending phase and mark it running
    complete <phase>   Mark a phase as done (e.g. complete SCOPE)
    fail <phase>       Mark a phase as failed
    report             Print all handoff reports for current sprint
    reset              Clear sprint state and prompt files

  Phases:
    SCOPE      product-owner         → defines user stories & acceptance criteria
    CONTRACT   api-architect         → designs endpoints & DB schema changes
    BACKEND    backend-implementer   → implements Fastify routes & migrations
    MOBILE     flutter-mobile-engineer → implements Flutter screens & providers
    QA         qa-reviewer           → runs automated checks & manual audit
    DOCS       documentation-writer  → updates API reference & changelog

  Files:
    .sprint-state.json       phase tracking state
    .sprint-prompts/<PHASE>.md   prompt to feed to each Claude agent
    .sprint-reports/<PHASE>.md   handoff reports written by each agent
  `);
}

// ─── Entry point ──────────────────────────────────────────────────────────────

const cmd = process.argv[2];
const arg = process.argv.slice(3).join(' ');

switch (cmd) {
  case 'start':    cmdStart(arg); break;
  case 'status':   cmdStatus(); break;
  case 'next':     cmdNext(); break;
  case 'complete': cmdComplete(process.argv[3]); break;
  case 'fail':     cmdFail(process.argv[3]); break;
  case 'reset':    cmdReset(); break;
  case 'report':   cmdReport(); break;
  default:         printHelp(); process.exit(0);
}
