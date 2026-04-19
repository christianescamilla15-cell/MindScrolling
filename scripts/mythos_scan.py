#!/usr/bin/env python
"""Run Mythos against MindScrolling using LOCAL targets + memory.

The bundled `mythos` CLI hardcodes `_repo_root()` to the amx-hallazgos-audit
install directory. This wrapper calls the pipeline API directly so findings
stay inside MindScrolling and never touch the framework repo.

Usage:
    python scripts/mythos_scan.py mindscrolling-backend
    python scripts/mythos_scan.py mindscrolling-backend --delta
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from mythos_core.memory import MythosMemory
from mythos_core.pipeline import Pipeline
from mythos_core.schemas import PolicyVerdict
from mythos_core.targets import find_profile

REPO_ROOT = Path(__file__).resolve().parent.parent
TARGETS_ROOT = REPO_ROOT / "mythos-targets"
MEMORY_ROOT = REPO_ROOT / "mythos-memory"


def main() -> int:
    parser = argparse.ArgumentParser(description="Mythos scan · MindScrolling local")
    parser.add_argument("target", help="Target id under mythos-targets/")
    parser.add_argument("--delta", action="store_true", help="Report deltas vs last scan")
    args = parser.parse_args()

    profile = find_profile(TARGETS_ROOT, args.target)
    memory = MythosMemory(MEMORY_ROOT)
    pipeline = Pipeline(memory=memory)
    report = pipeline.run(profile, repo_root=REPO_ROOT, delta_mode=args.delta)

    counts = {sev.name: 0 for sev in __import__("mythos_core.schemas", fromlist=["Severity"]).Severity}
    for f in report.findings:
        counts[f.severity.name] += 1
    print(f"Mythos · {args.target} · {report.run_id}")
    for sev, n in counts.items():
        print(f"  {sev:<9} {n}")
    print(f"Verdict: {report.verdict.name}")
    print(f"Artifacts: mythos-memory/runs/{report.run_id}/")

    return 0 if report.verdict == PolicyVerdict.PASS else 1


if __name__ == "__main__":
    sys.exit(main())
