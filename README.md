# Pi agent configuration

An opinionated, portable configuration for the [Pi coding agent](https://pi.dev). It keeps Pi's instructions, skills, and user-owned extensions independent from Codex, Claude Code, and other agent harnesses.

The repository is public so you can inspect every instruction sent to Pi, review changes through Git history, and adapt the setup for your own workflows.

## What this repository owns

- Global and workspace `AGENTS.md` guidance
- Independent Pi copies of the complete skill catalog
- User-owned Pi extensions
- Restore, validation, and explicit synchronization commands
- Explanatory documentation and context measurements

It deliberately excludes credentials, provider authentication, runtime settings, MCP machine bindings, package-managed source, model stores, sessions, logs, and caches.

## How it fits together

```text
GitHub: pi-agent-config
          │  git pull / reviewed changes
          ▼
local clone on main
          │  fail-closed symlinks
          ├── ~/.pi/agent/AGENTS.md
          ├── ~/.pi/agent/skills/*
          ├── ~/.pi/agent/extensions/tool-profiles.ts
          └── ~/Developer/AGENTS.md
```

The tracked files are the source of truth. Pi reads them through symlinks, so there are no generated copies to drift. See [Architecture](docs/architecture.md) for ownership and precedence details.

## Quick start

Requirements: Git, Bash, and an installed Pi coding agent. Some workflows also assume optional tools such as the BB CLI, a Linear MCP integration, or a repository-managed Infisical runner; restore does not install or configure them. See [customization guidance](docs/customizing.md) before relying on those workflows.

```bash
git clone https://github.com/maheen-ejaz/pi-agent-config.git ~/Developer/pi-agent-config
cd ~/Developer/pi-agent-config
bin/pi-config-restore
bin/pi-config-check
```

The restore command creates only missing links. It refuses to overwrite an existing file or a link to another source. Reconcile those paths deliberately, then retry.

Override installation locations when needed:

```bash
PI_AGENT_DIR=/path/to/pi-agent \
PI_WORKSPACE_ROOT=/path/to/workspace \
  bin/pi-config-restore
```

Restart Pi or run `/reload` after installation. Existing sessions retain earlier prompt and tool checkpoints; use `/new` to validate a clean startup.

## Keeping the configuration current

From the clean `main` checkout:

```bash
bin/pi-config-sync
```

The sync command:

1. Refuses dirty, non-`main`, diverged, or in-progress Git states.
2. Fetches `origin/main` and fast-forwards only.
3. Restores missing links without overwriting files.
4. Runs the complete configuration check.

It never runs in the background. To propose a change, use a task branch/worktree and open a pull request rather than editing the shared `main` checkout.

## Skill catalog

The repository currently ships 13 Pi-owned skills. Some are automatically applicable; most require explicit `/skill:<name>` invocation. See the [skill catalog](skills/README.md) for triggers and boundaries.

Pi also scans `~/.agents/skills` when present. Same-name Pi copies under `~/.pi/agent/skills` win discovery; `pi-config-check` ensures the complete Pi catalog is installed so another harness's copy cannot become the accidental fallback.

## Lean tool profiles

Fresh sessions keep ordinary coding and safety tools active. Specialized schemas activate only when required:

```text
/tool-profile web
/tool-profile browser
/tool-profile linear
/tool-profile core
```

Pi can call `activate_tool_profile` itself. Activation changes only tool visibility for the current session; it does not grant authorization or change the required `linear-direct` boundary.

## Learn and customize

- [Architecture and ownership](docs/architecture.md)
- [Safe customization guide](docs/customizing.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Startup-context measurements](docs/context-reduction.md)
- [Skill provenance](skills/SOURCES.md)

The governance is intentionally strict. Treat it as a documented example, not universal policy: understand each safety boundary before adapting it.

## Development

```bash
bash -n bin/pi-config-restore bin/pi-config-check bin/pi-config-sync tests/*.sh
bash tests/restore-test.sh
bash tests/catalog-test.sh
bash tests/sync-test.sh
(cd skills/repo-audit/scripts && python3 -m unittest apply_audit_markers_test select_audit_scope_test)
bin/pi-config-check --source-only
git diff --check
git diff --cached --check
```

No GitHub Actions workflow is used; checks run locally. Contributions are welcome through focused pull requests. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
