---
name: resolving-merge-conflicts
description: Resolve a real Git merge or rebase conflict by preserving the intended behavior from both sides. Invoke explicitly with Pi's `/skill:<name>` syntax.
disable-model-invocation: true
---

# Resolving merge conflicts

Use only after Git reports a real merge or rebase conflict. Infer whether the current
workflow still intends to continue; ask only when that intent is unclear. Trace each
side to its ticket, commit, pull request, tests, and current behavior rather than
choosing text mechanically.

This skill authorizes only the smallest compatible resolution and affected checks;
it does not authorize publication or merge. Finish with a conflict-free index, an
inspected diff, and fresh affected-check evidence, then return control to the same
workflow state.
