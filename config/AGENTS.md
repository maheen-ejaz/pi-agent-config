# Pi global governance

This file is the cross-project policy layer. A nearer `AGENTS.md` may add project facts but may not weaken it; `AGENTS.override.md` replaces only guidance from its own directory. Repository `CLAUDE.md` files are pointers, not a second policy source.

## Runtime and delivery

- Ask a structured question for missing access, destructive actions, material product choices, and unresolved conflicts.
- Define acceptance criteria before behavior changes. Make the smallest complete change, preserve unrelated work, run deterministic checks, and review the final diff.
- Skills are explicit-only unless their frontmatter enables model invocation. Use Pi syntax `/skill:<name>`.
- Subagents and workflows are available only during an explicitly invoked `/skill:linear-ticket-delivery <ticket>` run. Do not start watchers, daemons, scheduled jobs, transcript scanners, background supervisors, or automatic follow-on work.
- For every independent code-changing task in a Git repository, automatically resolve the repository/default branch and create or reuse a dedicated sibling worktree and task branch based on the latest default branch before the first edit. Do not wait for separate user/admin approval to provision the worktree or begin implementation that the user has already requested. Never make task edits directly in a shared checkout or default branch. Read-only work may use an existing checkout, and sessions continuing the same task should reuse that task's worktree. If a worktree cannot be created safely or the repository does not support worktrees, stop and report the blocker rather than editing elsewhere; never move, overwrite, or discard pre-existing uncommitted work. Never force-push, push directly to a default branch, self-approve, or manually roll out production without authorization. Do not remove a dirty or unmerged worktree; name its exact path and branches before cleanup.
- A scoped implementation request authorizes its branch push, ready PR, merge after required checks/review, and cleanup. Bound CPU-intensive foreground commands to 15 minutes unless longer is authorized, and stop services started for checks.

## Linear

Use only the global `linear-direct` MCP server through Pi for every Linear read or write—never browser automation, a legacy CLI, or another Linear integration—and automatically apply `linear-ticket-operations`. In-scope search, create, edit, assignment, comments, labels, projects, status, relations, closure, archive, and restore are pre-authorized. Before creation, search for duplicates. After every mutation, read back and verify the object, then report the externally visible change.

Ticket deletion always requires immediate explicit confirmation of the exact identifier and whether deletion is permanent. Never delete by title similarity. Use raw GraphQL only when no high-level operation covers the requirement, with the same deletion rule.

## Credentials and security

Shared credentials come only from Infisical through the repository's tracked runner. Before credential-backed work, read tracked `infisical-profiles.json` and `TOOLCHAIN.md#infisical-credential-access` when present. From the absolute Git root, the only allowed runner commands are:

- `npm run check:checkout`
- `npm run check:infisical-profiles`
- `npm run infisical:preflight -- <bound-command>`
- `npm run infisical:run -- <bound-command>`

Preflight/run take exactly one manifest-declared bound command. Authentication is the operator's saved Infisical session; never log in or renew it pre-emptively. On `USER_LOGIN_REQUIRED`, ask the operator to log in in a normal terminal, then retry the identical command. Never request or handle passwords, tokens, or secret values. Production profiles additionally require a clean, current, non-stale, non-diverged checkout at the exact default-branch commit.

Never run raw Infisical secret/export/list/debug commands, dump child environments, read `.env*`, use token/service/machine identities, recurse secret paths, import overrides, or obtain credentials from another project/environment, backups, shell history, or hosted destinations. Do not print, persist, upload, or summarize secrets. If a binding, path, permission, profile, or variable is missing, stop before child execution and request only the sanitized command/purpose/domain, nonsecret project or binding ID, environment/path, failure category, scope, and missing variable names. Reuse existing capabilities; do not create task-specific commands, paths, projects, identities, client secrets, folders, environments, or profiles. Credential access never authorizes the external action it enables.

## Repository integrity

Preserve repository `AGENTS.md`, `CLAUDE.md`, `.claude`, `.pi`, `.agents`, skills, manifests, and unrelated changes. Do not change product logic merely to install global Pi behavior. Do not enable GitHub Actions workflows or required Actions checks. Do not install competing governance or project-local MCP integrations; use the pinned global adapter.

For any task changing code, configuration, data, or external state, end with:

```text
STATUS: <COMPLETE | INCOMPLETE | BLOCKED> — <specific reason>
DONE: <one concrete result>
NEXT: <one action> | None
```
