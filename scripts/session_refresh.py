#!/usr/bin/env python3
"""Session refresh — update AI memory at end of work session."""
from __future__ import annotations

import argparse
from pathlib import Path


def ensure_memory(root: Path) -> None:
    (root / "ai-memory").mkdir(parents=True, exist_ok=True)
    for name in ["active_workstream.md", "recent_decisions.md", "known_risks.md"]:
        path = root / "ai-memory" / name
        if not path.exists():
            path.write_text(f"# {name.replace('.md','').replace('_',' ').title()}\n\n", encoding="utf-8")


def update_workstream(root: Path, summary: str, next_step: str, phase: str | None) -> None:
    path = root / "ai-memory" / "active_workstream.md"
    existing = path.read_text(encoding="utf-8") if path.exists() else ""

    # Preserve task, mode, spec from existing
    task = mode = spec = "Unknown"
    for line in existing.splitlines():
        stripped = line.strip()
        if stripped.startswith("## Current Task"):
            idx = existing.splitlines().index(line)
            if idx + 1 < len(existing.splitlines()):
                task = existing.splitlines()[idx + 1].strip() or task
        elif stripped.startswith("## Mode"):
            idx = existing.splitlines().index(line)
            if idx + 1 < len(existing.splitlines()):
                mode = existing.splitlines()[idx + 1].strip() or mode
        elif stripped.startswith("## Active Spec"):
            idx = existing.splitlines().index(line)
            if idx + 1 < len(existing.splitlines()):
                spec = existing.splitlines()[idx + 1].strip() or spec

    path.write_text(f"""# Active Workstream

## Current Task
{task}

## Mode
{mode}

## Active Spec
{spec}

## Current Phase
{phase or "In Progress"}

## Session Summary
{summary}

## Next Step
{next_step}
""", encoding="utf-8")


def append_file(root: Path, filename: str, title: str, content: str) -> None:
    if not content:
        return
    path = root / "ai-memory" / filename
    existing = path.read_text(encoding="utf-8") if path.exists() else f"# {title}\n\n"
    path.write_text(existing + f"\n## Session Update\n{content.strip()}\n\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Refresh AI memory after session")
    parser.add_argument("--summary", required=True, help="What was done")
    parser.add_argument("--next-step", required=True, help="What comes next")
    parser.add_argument("--phase", help="Current phase")
    parser.add_argument("--decisions", help="Durable decisions made")
    parser.add_argument("--risks", help="New risks discovered")
    parser.add_argument("--root", default=".", help="Project root")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    ensure_memory(root)
    update_workstream(root, args.summary, args.next_step, args.phase)
    append_file(root, "recent_decisions.md", "Recent Decisions", args.decisions)
    append_file(root, "known_risks.md", "Known Risks", args.risks)

    print(f"\n  Session memory updated.")
    print(f"  Summary   : {args.summary}")
    print(f"  Next step : {args.next_step}")
    if args.phase:
        print(f"  Phase     : {args.phase}")
    print()


if __name__ == "__main__":
    main()
