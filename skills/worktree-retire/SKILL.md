---
name: worktree-retire
description: Inventory Git worktrees and guide explicit, safe retirement of one verified worktree. Invoke explicitly with `/skill:worktree-retire [repository path]`.
disable-model-invocation: true
---

# Worktree inventory and retirement

Use only when explicitly invoked as `/skill:worktree-retire [repository path]`. If no path is supplied, use the current working directory. Inspect only that repository's linked worktrees.

## Inventory first

For every registered worktree, report its exact path, branch or detached state, `HEAD`, owning task metadata when available from `pi-task --list`, dirty/untracked paths, in-progress Git operations, upstream existence, and ahead/behind counts against both its upstream and the live default branch. Resolve the live default branch and SHA with `git ls-remote --symref origin HEAD`; do not trust a possibly stale local `origin/HEAD`. Refresh refs only with `git fetch --no-prune origin` and fetch that exact branch; never prune. Verify the fetched default SHA still matches live HEAD. If the current default cannot be resolved or keeps moving, stop before proposing removal.

Classify each worktree using these dispositions: `active`, `preserve-dirty`, `preserve-unmerged`, `blocked-ownership`, or `ready-for-admin-retirement-review`. A missing remote branch, old timestamp, closed ticket, clean status, or lack of a running Pi process is not proof that a worktree is unused. If ownership or activity is uncertain, preserve it. Where a user decision can safely resolve uncertainty, use `ask_user_question` to offer inspection, owner/activity confirmation, or leaving it unchanged; do not offer removal until all eligibility checks pass.

## Retirement eligibility

Do not propose removal for a dirty or untracked worktree, an in-progress Git operation, a detached/ambiguous worktree, a branch with commits not integrated into the current default branch, a worktree known to be active, or a worktree whose owner is unknown. Do not remove the repository's canonical default-branch checkout. Do not use `git worktree prune`, broad cleanup, age-based deletion, or `--force`.

For a clean, attached, fully integrated, non-default worktree, present its exact path, branch/ref, current `HEAD`, owner/task metadata, and what removal will do. Ask the user with `ask_user_question` whether to inspect further, keep it, or remove that exact worktree. The approval must bind to the displayed path, branch/ref, and `HEAD`; approval for one worktree never authorizes another.

Immediately before an approved removal, refresh and resolve the live default again, then revalidate repository identity, exact path, branch, `HEAD`, clean/untracked status, integration with the current default branch, owner confirmation, and absence of in-progress operations. If the default or any other checked state changed, stop and ask again. Use `git worktree remove <exact-path>` without force, then verify the path is gone and the registration is gone. Never delete the branch as part of worktree removal; branch deletion is a separate operation requiring its own exact approval.

For a stale registration whose directory is already missing, report it as blocked for separate exact repair. Do not run `git worktree prune`.

## Completion

Report all inspected worktrees and their dispositions, any exact approved removal, and why every other candidate was preserved. If no worktree qualifies, make no changes and say so.
