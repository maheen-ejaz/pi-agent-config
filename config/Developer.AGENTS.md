# Developer workspace guidance

This layer applies to repositories under `~/Developer`. Global security, credential, Linear, and delivery policy lives in `~/.pi/agent/AGENTS.md`; do not copy it into repositories.

## Repository instruction contract

- A repository `AGENTS.md` contains only that repository's commands, architecture, release checks, and invariants. Keep it concise and point to owned detail instead of duplicating it.
- A repository `CLAUDE.md` is only a pointer to `AGENTS.md`. `AGENTS.override.md` replaces guidance from the same directory, while parent and global layers still apply.
- Before edits, read the active repository guidance and check Git status. Preserve unrelated work and use the repository's deterministic checks.
- Do not add a bare `SYSTEM.md`; Pi loads only supported `.pi/SYSTEM.md` or `.pi/APPEND_SYSTEM.md` paths, and those require a demonstrated prompt-level need.

## Session discipline

- Use `/new` for an unrelated task or clean slate. Do not use `/clone`, `/fork`, or `/resume` when old context is unwanted.
- Use `/compact` during long, still-related work; compaction is lossy, so keep decisive state in the repository or a focused handoff.
- Use `/handoff <goal>` when switching to a focused continuation that needs selected context rather than the full history.
- Bound `read` with offsets/limits and shell/search output with narrow paths and filters. Collapsing tool output changes the UI only; it does not remove model context.
- Suggest handoff or compaction only at a natural checkpoint. Never mutate context or schedule follow-on work without the operator.
