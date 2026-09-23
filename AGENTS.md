# Pi agent configuration repository

This public repository versions portable, non-secret configuration for the Pi coding agent. Global governance still applies.

## Boundaries

- Never commit credentials, runtime settings, model stores, MCP machine bindings, session files, caches, logs, private repository data, or personal absolute paths.
- `config/AGENTS.md` owns Pi-global policy; `config/Developer.AGENTS.md` owns the default workspace delta. Do not duplicate them here.
- `skills/catalog.txt` lists every independently owned Pi skill. Keep its catalog entry, `SKILL.md`, README summary, and restore/check coverage aligned.
- Restore and sync tooling must fail rather than overwrite, discard, reset, rebase, or merge ambiguous state. It must not fetch credentials, install packages, or run in the background.
- Do not add GitHub Actions workflows.

## Checks

From the repository root run:

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

Review the complete diff and scan tracked files for secrets, private data, and machine-specific paths before publishing.
