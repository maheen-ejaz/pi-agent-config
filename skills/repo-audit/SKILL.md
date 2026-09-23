---
name: repo-audit
description: Run an explicit user-invoked repository audit in daily, weekly, or report mode against any repository. Invoke explicitly with Pi's `/skill:<name>` syntax.
disable-model-invocation: true
---

# Repository audit

Use only when the user explicitly invokes the `repo-audit` skill with `<mode> [repo ...]` where
mode is `daily`, `weekly`, or `report`. This skill never controls ordinary coding
and never runs on a schedule.

## Targets

Audit only repositories named at invocation. Accept absolute paths or
`owner/name`, and derive each GitHub identity with `git remote get-url origin`
rather than assuming a path layout. If no repository is named, ask for the target
instead of scanning the workspace or inventing a default set.

## Modes

`daily` and `weekly` are repair-authorized and require a GitHub remote and `gh`.
`report` is read-only and works on any repository, including one with no remote.

For `daily` and `weekly`, run `gh pr list --repo <owner/name> --state merged
--limit 1000 --json number,mergedAt,labels` from any directory, then pipe that JSON
to `python3 <this-skill-directory>/scripts/select_audit_scope.py --mode
<daily|weekly>`.

- **Daily:** find the newest merged PR labelled `audit:daily` and review every
  later merged PR together against its current default branch. With no marker,
  audit the current default branch as the baseline. After successful completion,
  label every reviewed PR; a baseline labels only the newest merged PR.
- **Weekly:** audit the complete current repositories regardless of labels. Use
  `audit:weekly` only to mark recently reviewed PRs; it never narrows later weekly
  scope.
- **Report:** audit commits since the last successful audit, capped at 30 days
  unless `--full` is explicit. Record the commit range and affected paths before
  review; include only direct dependencies and critical affected paths. Verify at
  most ten candidates and return at most three confirmed, high-confidence,
  in-scope issues. No findings requires no follow-up.

Create missing labels only when the audit is invoked, and only in `daily` or
`weekly`. After all repairs, checks, delivery, production verification, and
cleanup succeed, pass markerTargets to `scripts/apply_audit_markers.py`. It rolls
back labels added by an incomplete batch. Marker application failure leaves the
audit INCOMPLETE; never report successful coverage from a partial batch.

## Authority and checks

Authority scales with mode.

**`report` owns the audit report only** — not repairs, Linear state, branches,
markers, or publication. Make no code, label, ticket, or branch changes. Deliver
any selected repair batch afterwards through a separate bounded coding task using
the repository's current guidance.

**`daily` and `weekly`** authorize read-only production health checks and safe
repairs through one owned branch and at most one PR per affected repository. Run
the repositories' fast PR checks, affected checks across the selected merge range,
broad product and security invariants, and one local database/migration/RLS/ACL
replay. Check current production health and migration parity from each trusted
default branch where applicable.

Start Colima only for database work. Record whether it was already running; stop it
only if the audit started it, and verify audit-owned containers and processes are
gone before completion.

In every mode, do not mutate production data, apply production migrations, change
credentials, send provider traffic, perform manual deployments or app-store
submissions, expand permissions, or make product-policy decisions without separate
user authorization.

## Repairs and review

In `daily` and `weekly`, repair confirmed findings automatically. Allow four
productive repair cycles, then use the structured question tool for two more. If
findings remain after six, request four-cycle batches; each batch needs fresh user
approval. Never fail silently.

Review the changed surface once. For security, payments, destructive data,
migrations, deployment, or comparable high-risk work, use exactly one isolated,
blind, read-only reviewer after checks. In `report` mode add that reviewer only
when the audited change is high-risk. Merge safe verified repairs, verify
deployment and release health, and clean the owned worktree and branches.

## Linear

In `daily` and `weekly`, update an explicitly identified ticket with factual
evidence and close it only after `COMPLETE`. For additional or optional work, ask
once whether the user authorizes ticket creation. After consent, search for
duplicates and create the necessary tickets using best judgment. Do not ask the
user to review titles or scope, and do not start another coding task. `report`
mode makes no Linear writes.

## Completion

Report the mode, the audited repositories, the audited PR range or commit range,
checks, repairs, PRs, production health, markers applied, Linear writes, and
cleanup. For `report`, give evidence for each confirmed finding and any unresolved
item with its owner and next trigger. No coordinator, routing lock, audit state,
receipt, agent lane, convergence loop, watcher, or background process is permitted.
