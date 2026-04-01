#!/usr/bin/env python3
"""Kiro-style task scaffold generator v2.
Detects mode, creates spec folders, updates memory, prints execution prompt.
"""
from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple

VALID_MODES = {"BUGFIX", "FEATURE", "MIGRATION", "LEGACY_MODERNIZATION"}


@dataclass
class TaskContext:
    task: str
    mode: str
    slug: str
    spec_dir: Path
    root: Path
    context: str | None = None


def slugify(text: str) -> str:
    text = text.strip().lower()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    text = re.sub(r"-{2,}", "-", text).strip("-")
    return text[:90] or "untitled-task"


def score_mode(task: str, context: str | None = None) -> Tuple[str, Dict[str, int]]:
    text = " ".join(p.strip().lower() for p in [task, context] if p and p.strip())

    keyword_map = {
        "MIGRATION": {
            "migrate": 5, "migration": 5, "move to aws": 5, "move to cloud": 5,
            "monolith": 4, "microservice": 5, "microservices": 5, "dockerize": 4,
            "containerize": 4, "ecs": 3, "eks": 3, "kubernetes": 4, "rds": 3,
            "terraform": 3, "database migration": 5, "rewrite in": 4, "port to": 4,
            "on-prem": 4, "framework migration": 5, "ci/cd modernization": 4,
        },
        "LEGACY_MODERNIZATION": {
            "legacy": 5, "technical debt": 5, "stabilize": 4, "cleanup": 4,
            "decouple": 4, "reduce coupling": 5, "refactor old": 4, "modernize": 5,
            "document old": 4, "improve test coverage": 4, "tightly coupled": 4,
            "prepare for future migration": 5, "hard to maintain": 3,
        },
        "BUGFIX": {
            "fix": 4, "bug": 4, "broken": 5, "crash": 5, "failing": 4,
            "error": 4, "regression": 5, "white screen": 5, "not working": 5,
            "doesn't work": 5, "misaligned": 4, "incorrect": 4, "layout broken": 5,
        },
        "FEATURE": {
            "add": 3, "create": 3, "build": 3, "new feature": 5, "new module": 4,
            "new dashboard": 4, "analytics": 3, "integration": 3, "new endpoint": 4,
            "new page": 4, "export": 3, "automation": 3,
        },
    }

    scores = {mode: 0 for mode in VALID_MODES}
    for mode, mapping in keyword_map.items():
        for phrase, weight in mapping.items():
            if phrase in text:
                scores[mode] += weight

    if scores["MIGRATION"] >= 5:
        return "MIGRATION", scores
    if scores["LEGACY_MODERNIZATION"] >= 5 and scores["MIGRATION"] < 5:
        return "LEGACY_MODERNIZATION", scores
    if scores["BUGFIX"] >= 4 and scores["MIGRATION"] < 5:
        return "BUGFIX", scores

    best = max(scores, key=scores.get)
    return (best if scores[best] > 0 else "FEATURE"), scores


def get_prefix(mode: str) -> str:
    return {"BUGFIX": "bugfix", "FEATURE": "feature", "MIGRATION": "migration", "LEGACY_MODERNIZATION": "legacy"}[mode]


def get_spec_files(mode: str) -> List[str]:
    base = {
        "BUGFIX": ["bugfix.md", "design.md", "tasks.md", "validation.md", "rollback.md", "risks.md"],
        "FEATURE": ["requirements.md", "design.md", "tasks.md", "validation.md", "rollout.md", "risks.md"],
        "MIGRATION": ["requirements.md", "design.md", "tasks.md", "validation.md", "rollout.md", "rollback.md", "risks.md"],
        "LEGACY_MODERNIZATION": ["requirements.md", "design.md", "tasks.md", "modernization-roadmap.md", "validation.md", "rollback.md", "risks.md"],
    }
    return base[mode]


def file_template(filename: str, ctx: TaskContext) -> str:
    title = f"{ctx.mode.replace('_', ' ').title()} - {ctx.task}"
    ctx_block = f"\n## Additional Context\n{ctx.context}\n" if ctx.context else ""

    templates = {
        "bugfix.md": f"# {title}\n\n## Problem Statement\n\n## Symptoms\n\n## Expected Behavior\n\n## Actual Behavior\n\n## Reproduction Steps\n1.\n2.\n3.\n\n## Likely Root Cause\n\n## Acceptance Criteria\n- [ ] Bug resolved\n- [ ] No regressions\n- [ ] Tests added\n{ctx_block}",
        "requirements.md": f"# {title}\n\n## Objective\n\n## User Impact\n\n## Functional Requirements\n\n## Non-Functional Requirements\n\n## Acceptance Criteria\n- [ ] \n\n## Out of Scope\n{ctx_block}",
        "design.md": f"# {title}\n\n## Current State\n\n## Proposed Design\n\n## Architecture Impact\n\n## Tradeoffs\n\n## Risks\n{ctx_block}",
        "tasks.md": f"# {title}\n\n## Tasks\n\n### T1\n- Description:\n- Owner Agent:\n- Dependencies:\n- Validation:\n- Risk: low/medium/high\n\n### T2\n- Description:\n- Owner Agent:\n- Dependencies:\n- Validation:\n- Risk: low/medium/high\n{ctx_block}",
        "validation.md": f"# {title}\n\n## Checklist\n- [ ] Scope correct\n- [ ] Tests identified\n- [ ] Edge cases reviewed\n- [ ] No unrelated changes\n\n## Test Matrix\n- Unit:\n- Integration:\n- Regression:\n{ctx_block}",
        "rollback.md": f"# {title}\n\n## Rollback Conditions\n\n## Rollback Steps\n1.\n2.\n\n## Post-Rollback Verification\n{ctx_block}",
        "rollout.md": f"# {title}\n\n## Rollout Plan\n\n## Deployment Steps\n1.\n2.\n\n## Post-Deploy Checks\n- [ ] Main flow works\n- [ ] Logs healthy\n{ctx_block}",
        "risks.md": f"# {title}\n\n## Known Risks\n\n## Mitigations\n\n## Open Questions\n{ctx_block}",
        "modernization-roadmap.md": f"# {title}\n\n## Quick Wins\n\n## Medium-Term Cleanup\n\n## High-Risk Refactors\n\n## Future Migration Readiness\n{ctx_block}",
    }
    return templates.get(filename, f"# {title}\n\n{ctx_block}")


def ensure_base_structure(root: Path) -> None:
    for d in ["ai-memory", "specs", "scripts", "ai-system", "docs"]:
        (root / d).mkdir(parents=True, exist_ok=True)

    defaults = {
        "product_context.md": "# Product Context\n\nDescribe the product, users, and critical workflows.\n",
        "tech_context.md": "# Tech Context\n\nDescribe the stack, tooling, and infrastructure.\n",
        "architecture_context.md": "# Architecture Context\n\nDescribe modules, services, and dependencies.\n",
        "active_workstream.md": "# Active Workstream\n\nNo active workstream yet.\n",
        "recent_decisions.md": "# Recent Decisions\n\n",
        "known_risks.md": "# Known Risks\n\n",
    }
    for name, content in defaults.items():
        path = root / "ai-memory" / name
        if not path.exists():
            path.write_text(content, encoding="utf-8")


def create_spec_files(ctx: TaskContext) -> None:
    ctx.spec_dir.mkdir(parents=True, exist_ok=True)
    for f in get_spec_files(ctx.mode):
        path = ctx.spec_dir / f
        if not path.exists():
            path.write_text(file_template(f, ctx), encoding="utf-8")


def update_memory(root: Path, ctx: TaskContext, scores: Dict[str, int]) -> None:
    # active_workstream.md
    (root / "ai-memory" / "active_workstream.md").write_text(f"""# Active Workstream

## Current Task
{ctx.task}

## Mode
{ctx.mode}

## Active Spec
{ctx.spec_dir.as_posix()}

## Current Phase
Context Discovery

## Next Step
Fill spec files, then run execution prompt.
""", encoding="utf-8")

    # recent_decisions.md
    path = root / "ai-memory" / "recent_decisions.md"
    existing = path.read_text(encoding="utf-8") if path.exists() else "# Recent Decisions\n\n"
    path.write_text(existing + f"\n## Started {ctx.slug}\n- Task: {ctx.task}\n- Mode: {ctx.mode}\n- Scores: {scores}\n\n", encoding="utf-8")


def build_prompt(ctx: TaskContext) -> str:
    spec_path = ctx.spec_dir.as_posix()
    base = f"Task: {ctx.task}\nActive spec: {spec_path}"

    if ctx.mode == "BUGFIX":
        return f"""Act as a Kiro-style spec-driven system for BUGFIX work.
Do not jump to the fix. First analyze, isolate, document, then implement.

Phases: Context Discovery -> Steering Check -> Bugfix Spec -> Root Cause -> Surgical Fix -> Regression Tests -> Release Safety

Rules: surgical fixes only, no unrelated refactors, add regression tests, document root cause.

{base}

Read /ai-memory/ first, then work through the spec files in {spec_path}."""

    if ctx.mode == "FEATURE":
        return f"""Act as a Kiro-style spec-driven system for FEATURE development.
Do not code first. Follow: Context -> Steering -> Spec -> Agents -> Implementation -> Validation -> Release.

Rules: preserve existing behavior, incremental additions, tests for critical paths, document changes.

{base}

Read /ai-memory/ first, then work through the spec files in {spec_path}."""

    if ctx.mode == "MIGRATION":
        return f"""Act as a Kiro-style enterprise MIGRATION system.
Do not jump to coding. Follow: Discovery -> Steering -> Spec -> Agent Execution -> Artifacts -> Validation -> Deploy.

Rules: phased migration (strangler pattern), no big-bang rewrites, backward compatibility, rollback for each phase.

{base}

Read /ai-memory/ first, then work through the spec files in {spec_path}."""

    if ctx.mode == "LEGACY_MODERNIZATION":
        return f"""Act as a Kiro-style LEGACY MODERNIZATION system.
Objective: stabilize and modernize safely. Follow: Discovery -> Mapping -> Spec -> Incremental Refactor -> Tests -> Stabilization -> Docs.

Rules: stability first, avoid large rewrites, add tests around fragile areas, quick wins before risky refactors.

{base}

Read /ai-memory/ first, then work through the spec files in {spec_path}."""

    return f"Unknown mode: {ctx.mode}"


def main() -> None:
    parser = argparse.ArgumentParser(description="Kiro-style task scaffold generator v2")
    parser.add_argument("--task", required=True, help="Task description")
    parser.add_argument("--mode", choices=sorted(VALID_MODES), help="Force mode")
    parser.add_argument("--context", help="Extra context")
    parser.add_argument("--root", default=".", help="Project root")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    ensure_base_structure(root)

    if args.mode:
        mode, scores = args.mode, {m: 0 for m in VALID_MODES}
    else:
        mode, scores = score_mode(args.task, args.context)

    prefix = get_prefix(mode)
    slug = f"{prefix}-{slugify(args.task)}"
    spec_dir = root / "specs" / slug

    ctx = TaskContext(task=args.task, mode=mode, slug=slug, spec_dir=spec_dir, root=root, context=args.context)

    create_spec_files(ctx)
    update_memory(root, ctx, scores)
    prompt = build_prompt(ctx)

    print(f"\n{'='*60}")
    print(f"  TASK SCAFFOLD CREATED")
    print(f"{'='*60}")
    print(f"  Mode     : {ctx.mode}")
    print(f"  Folder   : {ctx.spec_dir}")
    print(f"  Files    : {', '.join(get_spec_files(ctx.mode))}")
    if not args.mode:
        print(f"  Scores   : {scores}")
    print(f"{'='*60}")
    print(f"\n{'='*60}")
    print(f"  PASTE THIS PROMPT IN CLOUDCODE")
    print(f"{'='*60}\n")
    print(prompt)
    print(f"\n{'='*60}\n")


if __name__ == "__main__":
    main()
