# Startup-context reduction

GOO-1395 reduced Pi's everyday startup context while preserving coding, web, browser, and Linear workflows.

## Measurements

| Metric | Before | After |
|---|---:|---:|
| Initial tool declarations | 47 | 12 |
| Compact serialized tool JSON | 36,609 chars | 7,490 chars |
| Recorded system sections | 14,290 chars | 9,380 chars |
| Workspace `project_context` | 7,262 chars | 6,473 chars |
| Skills section | 1,047 chars | 1,047 chars |
| First-request provider `input` | 10,419 tokens | 3,617 tokens |
| First-request cache read/write | 0 / 0 | 0 / 0 |
| First-response `totalTokens` | 10,656 | 3,622 |

Tool-schema characters fell about 79.5%; reported first-request input fell about 65.3%. These are operational samples rather than a perfectly controlled benchmark. Serialized characters are not tokens. Provider `input` excludes cache reads/writes, while session totals aggregate every turn.

Changing profiles appends a system/tool patch and may miss the preceding prompt cache once. Later requests can reuse the stable profile prefix.

## Verification

- Core coding used file tools with the lean startup set.
- Web activation enabled four web tools and completed a search.
- Browser activation opened, observed, and closed a managed page.
- Linear activation used `linear-direct` to read an issue.
- Workspace inheritance loaded global, workspace, and repository guidance once.
- `AGENTS.override.md` replaced same-directory `AGENTS.md`; `CLAUDE.md` was not loaded alongside `AGENTS.md`.
- Explicit shared-skill invocation worked after duplicate consolidation.
- No watcher, daemon, scheduler, transcript scanner, or automatic context mutation was introduced.

## Session convention

- Use `/new` for an unrelated task or clean slate.
- Use `/compact` for long but related work; preserve decisive state outside the lossy summary.
- Use `/handoff <goal>` for a focused continuation.
- Bound file, shell, and search output. UI collapse does not remove model context.
- Agents may suggest handoff or compaction at natural checkpoints but must not trigger unsolicited context changes.

## Tradeoffs

- A specialized workflow takes one activation step.
- The current Linear profile activates direct read/write tools plus generic MCP tools for compatibility. A future measured change may split read, write, and proxy profiles without changing the `linear-direct` boundary.
- Large repository instruction files can still dominate context and should be reduced only in repository-scoped work.
- Pi and cross-harness Linear skills intentionally retain different owners; the Pi copy must continue to win Pi discovery.

## Rollback model

Configuration is installed through symlinks. Roll back by checking out the intended repository revision, then restart Pi or run `/reload`. Existing sessions retain their earlier system/tool checkpoints, so validate with a fresh session.
