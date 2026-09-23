# Architecture and ownership

## Design goal

Pi should have one inspectable source of truth that does not depend on Codex or Claude Code configuration. GitHub provides history and collaboration; the local clone provides the exact files Pi reads.

## Ownership layers

1. `config/AGENTS.md` — short, mandatory cross-project boundaries.
2. `config/Developer.AGENTS.md` — workspace-specific repository and session guidance.
3. Repository `AGENTS.md` — only project commands, architecture, checks, and invariants.
4. `skills/*/SKILL.md` — detailed workflows loaded progressively when relevant.
5. `extensions/` — user-authored Pi runtime behavior.

This keeps always-on context small while retaining detailed procedures on demand.

## Installation model

`bin/pi-config-restore` creates absolute symlinks from Pi's standard paths to the clone. It never replaces an existing regular file or unexpected link. `bin/pi-config-check` verifies every link, the complete skill manifest, forbidden file names, and common secret patterns. Task worktrees use `bin/pi-config-check --source-only` because live links should continue pointing at the clean main checkout until changes merge.

Absolute links make the active source unambiguous. Moving the clone requires removing the old links deliberately and running restore from the new location.

## Skill separation

The skill files in this repository are independent Pi copies. They may share historical origins with another harness, but Pi does not read that repository to obtain their content. Provider-specific agent metadata is excluded; each copy contains only Pi skill instructions and resources.

Pi natively scans both `~/.pi/agent/skills` and `~/.agents/skills`. When another harness also installs a same-name skill, Pi's own location has precedence. The configuration check prevents a missing Pi copy from silently changing ownership.

## Explicit synchronization

`bin/pi-config-sync` is intentionally foreground-only. It accepts only a clean `main` checkout that can fast-forward to `origin/main`, then restores links and validates the result. It does not commit, push, merge divergent branches, clean files, or run periodically.

Changes follow ordinary review:

```text
fresh origin/main → task worktree/branch → local checks → pull request → merge
```

After merge, run sync from the clean main checkout and `/reload` or `/new` in Pi.

## Excluded runtime state

The repository does not own:

- API credentials or provider login state
- `auth.json`, runtime `settings.json`, or model stores
- machine-bound MCP launcher paths
- package-managed extension implementation
- sessions, caches, logs, or temporary files

Those have different security, portability, and lifecycle requirements. Safe examples or templates can be documented without committing live machine state.
