---
name: infisical-credential-access
description: Automatically govern credential-backed work through repository-declared Infisical runners. Load before any task needs shared credentials, secret-bound commands, or production credential profiles.
---

# Infisical credential access

Shared credentials come only from Infisical through the active repository's tracked runner. Before credential-backed work, read tracked `infisical-profiles.json` and `TOOLCHAIN.md#infisical-credential-access` when present.

From the absolute Git root, the only allowed runner commands are:

- `npm run check:checkout`
- `npm run check:infisical-profiles`
- `npm run infisical:preflight -- <bound-command>`
- `npm run infisical:run -- <bound-command>`

Preflight/run take exactly one manifest-declared bound command. Authentication is the operator's saved Infisical session; never log in or renew it pre-emptively. On `USER_LOGIN_REQUIRED`, ask the operator to log in in a normal terminal, then retry the identical command. Never request or handle passwords, tokens, or secret values.

Production profiles additionally require a clean, current, non-stale, non-diverged checkout at the exact default-branch commit.

Never run raw Infisical secret/export/list/debug commands, dump child environments, read `.env*`, use token/service/machine identities, recurse secret paths, import overrides, or obtain credentials from another project/environment, backups, shell history, or hosted destinations. Do not print, persist, upload, or summarize secrets.

If a binding, path, permission, profile, or variable is missing, stop before child execution. Request only the sanitized command/purpose/domain, nonsecret project or binding ID, environment/path, failure category, scope, and missing variable names. Reuse existing capabilities; do not create task-specific commands, paths, projects, identities, client secrets, folders, environments, or profiles.

Credential access never authorizes the external action it enables.
