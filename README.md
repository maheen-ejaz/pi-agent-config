# Pi agent configuration

Portable, public configuration for the [Pi coding agent](https://pi.dev). This repository keeps Pi-specific governance and capabilities separate from the cross-harness [`agents-config`](https://github.com/maheen-ejaz/agents-config) repository.

## Contents

| Path | Purpose |
|---|---|
| `config/AGENTS.md` | Global Pi governance installed at `~/.pi/agent/AGENTS.md` |
| `config/Developer.AGENTS.md` | Workspace guidance installed at `~/Developer/AGENTS.md` by default |
| `extensions/tool-profiles.ts` | Lean startup profile with on-demand web, browser, and Linear tools |
| `skills/linear-ticket-operations/` | Pi-only `linear-direct` Linear workflow |
| `skills/linear-ticket-delivery/` | Pi-only ticket delivery and delegation workflow |
| `bin/pi-config-restore` | Creates missing configuration symlinks; refuses to overwrite files |
| `bin/pi-config-check` | Verifies source-of-truth links and basic safety invariants |
| `docs/context-reduction.md` | GOO-1395 measurements, verification, tradeoffs, and rollback model |

This repository deliberately excludes credentials, provider settings, MCP launcher configuration, model catalogs, sessions, caches, and machine-specific package state.

## Install or restore

```bash
git clone https://github.com/maheen-ejaz/pi-agent-config.git ~/Developer/pi-agent-config
cd ~/Developer/pi-agent-config
bin/pi-config-restore
bin/pi-config-check
```

The restore command is fail-closed: it creates a link only when the destination is absent or already points to the expected source. Move or reconcile existing files deliberately before retrying.

Override locations when needed:

```bash
PI_AGENT_DIR=/path/to/pi-agent \
PI_WORKSPACE_ROOT=/path/to/workspace \
  bin/pi-config-restore
```

Restart Pi or run `/reload` after changing installed configuration. Existing session history retains its prior prompt/tool checkpoints.

## Tool profiles

Fresh sessions keep ordinary coding and safety tools active. Specialized tools are registered but hidden until needed:

```text
/tool-profile web
/tool-profile browser
/tool-profile linear
/tool-profile core
```

The model can call `activate_tool_profile` itself. Profile activation changes tool declarations for the current session; it does not grant authorization or change the required `linear-direct` boundary.

## Development

```bash
bash -n bin/pi-config-restore bin/pi-config-check tests/restore-test.sh
bash tests/restore-test.sh
bin/pi-config-check
git diff --check
```

No GitHub Actions workflow is used. Run checks locally before committing.
