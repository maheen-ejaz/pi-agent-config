# Pi agent configuration repository

This public repository versions portable, non-secret configuration for the Pi coding agent. Global governance still applies.

## Boundaries

- Never commit `auth.json`, `settings.json`, `models*.json`, `mcp.json`, session files, caches, logs, secrets, tokens, machine-specific launcher paths, or private repository data.
- `config/AGENTS.md` owns Pi-global policy. `config/Developer.AGENTS.md` owns the default workspace delta. Do not duplicate either in this file.
- `skills/` contains only Pi-specific variants. Cross-harness skills remain owned by the separate `agents-config` repository.
- Restore tooling must fail rather than overwrite a non-symlink target. Installation must not fetch credentials, install packages, or mutate external services.
- Do not add GitHub Actions workflows.

## Checks

From the repository root run:

```bash
bash -n bin/pi-config-restore bin/pi-config-check tests/restore-test.sh
bash tests/restore-test.sh
bin/pi-config-check
```

Review `git diff --check` and scan tracked files for secret-like or machine-specific content before publishing.
