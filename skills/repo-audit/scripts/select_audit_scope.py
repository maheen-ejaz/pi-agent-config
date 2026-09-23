#!/usr/bin/env python3
"""Select informational PR marker scope for an explicit repository audit."""

from __future__ import annotations

import argparse
from datetime import datetime
import json
import sys
from typing import Any


LABELS = {"daily": "audit:daily", "weekly": "audit:weekly"}


def timestamp(value: str) -> datetime:
    return datetime.fromisoformat(value.replace("Z", "+00:00"))


def label_names(item: dict[str, Any]) -> set[str]:
    labels = item.get("labels", [])
    if not isinstance(labels, list):
        raise ValueError("PR labels must be a list")
    names: set[str] = set()
    for label in labels:
        if isinstance(label, str):
            names.add(label)
        elif isinstance(label, dict) and isinstance(label.get("name"), str):
            names.add(label["name"])
        else:
            raise ValueError("PR labels must contain names")
    return names


def select_scope(items: list[dict[str, Any]], mode: str) -> dict[str, Any]:
    if mode not in LABELS:
        raise ValueError("mode must be daily or weekly")

    merged: list[tuple[datetime, int, set[str]]] = []
    for item in items:
        number = item.get("number")
        merged_at = item.get("mergedAt")
        if not isinstance(number, int) or not isinstance(merged_at, str):
            raise ValueError("each PR must contain integer number and mergedAt")
        merged.append((timestamp(merged_at), number, label_names(item)))
    merged.sort()

    marker = LABELS[mode]
    checkpoints = [item for item in merged if marker in item[2]]
    checkpoint = checkpoints[-1] if checkpoints else None
    baseline = checkpoint is None
    selected = [item for item in merged if checkpoint is not None and item[:2] > checkpoint[:2]]

    if baseline:
        marker_targets = [merged[-1][1]] if merged else []
    else:
        marker_targets = [item[1] for item in selected]

    return {
        "mode": mode,
        "marker": marker,
        "baseline": baseline,
        "fullRepository": mode == "weekly" or baseline,
        "checkpointPr": checkpoint[1] if checkpoint else None,
        "selectedPrs": [item[1] for item in selected],
        "markerTargets": marker_targets,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", required=True, choices=sorted(LABELS))
    args = parser.parse_args()
    payload = json.load(sys.stdin)
    if not isinstance(payload, list):
        raise SystemExit("input must be a JSON array of merged PRs")
    print(json.dumps(select_scope(payload, args.mode), sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
