#!/usr/bin/env python3
"""Apply audit PR labels with rollback when a batch does not complete."""

from __future__ import annotations

import argparse
import json
import subprocess
from typing import Callable


Runner = Callable[[list[str]], None]
LabelCheck = Callable[[str, int, str], bool]


def command_runner(command: list[str]) -> None:
    subprocess.run(command, check=True)


def github_has_label(repository: str, pr: int, label: str) -> bool:
    result = subprocess.run(
        ["gh", "pr", "view", str(pr), "--repo", repository, "--json", "labels"],
        check=True,
        capture_output=True,
        text=True,
    )
    payload = json.loads(result.stdout)
    return any(item.get("name") == label for item in payload.get("labels", []))


def apply_markers(
    repository: str,
    label: str,
    prs: list[int],
    run: Runner = command_runner,
    has_label: LabelCheck = github_has_label,
) -> None:
    added: list[int] = []
    try:
        for pr in prs:
            if has_label(repository, pr, label):
                continue
            run(["gh", "pr", "edit", str(pr), "--repo", repository, "--add-label", label])
            added.append(pr)
    except BaseException:
        rollback_errors: list[int] = []
        for pr in reversed(added):
            try:
                run(["gh", "pr", "edit", str(pr), "--repo", repository, "--remove-label", label])
            except BaseException:
                rollback_errors.append(pr)
        if rollback_errors:
            raise RuntimeError(f"marker rollback failed for PRs: {rollback_errors}")
        raise


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", required=True)
    parser.add_argument("--label", required=True, choices=["audit:daily", "audit:weekly"])
    parser.add_argument("prs", nargs="+", type=int)
    args = parser.parse_args()

    command_runner([
        "gh", "label", "create", args.label, "--repo", args.repo,
        "--color", "6f42c1", "--description", "Informational repository audit marker",
        "--force",
    ])
    apply_markers(args.repo, args.label, args.prs)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
