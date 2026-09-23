# Pi global governance

This is the cross-project policy layer. A nearer `AGENTS.md` may add project facts but not weaken it; `AGENTS.override.md` replaces only guidance from its own directory. Repository `CLAUDE.md` files are pointers, not a second policy source.

## Work and delivery

- Ask a structured question for missing access, destructive actions, material product choices, and unresolved conflicts.
- Define acceptance criteria before behavior changes. Make the smallest complete change, preserve unrelated work, run deterministic checks, and review the final diff.
- Skills are explicit-only when their frontmatter says so. Invoke them with `/skill:<name>`.
- Subagents and workflows are available only during an explicitly invoked `/skill:linear-ticket-delivery <ticket>` run. Never start watchers, daemons, scheduled jobs, transcript scanners, background supervisors, or automatic follow-on work.
- Before the first repository edit, fetch the configured default ref and create or reuse a task-owned sibling worktree and branch from it. Record the owner, canonical repo/worktree paths, branch, HEAD, fetched default SHA, and fetch time. Never edit a shared checkout or default branch; stop if safe isolation is unavailable.
- A scoped implementation request authorizes its branch push, ready PR, and merge after required checks/review. Never force-push, push to a default branch, self-approve, or manually roll out production without authorization.
- Before task close, refresh the default ref and revalidate identity, HEAD, dirty/in-progress state, ownership, and integration evidence. Record one disposition: `active`, `preserve-dirty`, `preserve-unmerged`, `blocked-ownership`, or `ready-for-admin-retirement-review`. Cleanup requires immediate structured approval naming the exact path, branch/ref, and HEAD; preserve anything dirty, active, ambiguous, unowned, or unmerged.
- Bound CPU-intensive foreground commands to 15 minutes unless longer is authorized, and stop services started for checks.

## Linear

Use only Pi's global `linear-direct` MCP integration and automatically apply `linear-ticket-operations`; never use browser automation, a legacy CLI, or another Linear integration. In-scope operations are pre-authorized except deletion, which requires immediate confirmation of the exact identifier and permanence. Search before creation, read back every mutation, and report the visible result.

## Credentials and security

Before credential-backed work, load and follow `infisical-credential-access`. Never request, handle, print, persist, upload, or summarize secret values. Credential access never authorizes the external action it enables.

## Repository integrity

Preserve repository guidance, agent configuration, manifests, and unrelated changes. Do not alter product logic to install global Pi behavior, enable GitHub Actions or required Actions checks, or add competing governance/MCP integrations.

For any task changing code, configuration, data, or external state, end with:

```text
STATUS: <COMPLETE | INCOMPLETE | BLOCKED> — <specific reason>
DONE: <one concrete result>
NEXT: <one action> | None
```
