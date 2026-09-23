# Safe customization

## Start with the narrowest owner

- Universal non-negotiable boundary → `config/AGENTS.md`
- Workspace convention → `config/Developer.AGENTS.md`
- Project fact or command → that repository's `AGENTS.md`
- Detailed repeatable procedure → a skill
- Runtime behavior or tool registration → an extension
- Explanation for humans → documentation

Avoid copying the same rule across layers. Pi concatenates applicable instruction files, so duplication consumes context and creates conflicting owners.

## Adding or changing a skill

1. Create or edit `skills/<name>/SKILL.md`.
2. Use valid `name` and specific `description` frontmatter.
3. Add `disable-model-invocation: true` when the skill must be explicit-only.
4. Add the name to `skills/catalog.txt` in sorted order.
5. Update `skills/README.md` with its trigger and purpose.
6. Stage the intended skill files so the Git-backed source check can verify they are tracked.
7. Run restore/check tests and invoke the skill in a fresh Pi session.

Do not copy a skill from another agent harness without reviewing its tools, syntax, authorization boundaries, and side effects.

## Adapting optional integrations

Some included workflows assume external capabilities such as the BB CLI, a `linear-direct` MCP server, or a repository-declared Infisical runner. This repository describes those boundaries but does not install the tools or include their credentials and machine-specific bindings. If your setup differs, customize or disable the relevant workflow before relying on it; do not add local secrets or launcher paths to this public repository.

## Changing global guidance

Keep global guidance short and enforceable. State triggers, authority boundaries, prohibitions, and observable completion criteria. Move command lists, recovery branches, and long examples into skills or docs.

Before removing a global rule, confirm that its replacement is discoverable before the protected action occurs. Security and destructive-action boundaries should not depend on an obscure manual document.

## Changing an extension

Follow Pi's installed extension documentation and test in a fresh no-session invocation where possible. Tool activation affects provider prompt state and may cause one cache miss. Never use extensions to bypass authorization, start background supervisors, or mutate session context without operator intent.

## Publishing safely

Before pushing a public change:

- Run all local checks.
- Review the full diff, not only the file list.
- Search for home-directory paths, private hostnames, applicant data, tokens, and secret-like values.
- Do not commit runtime settings or session transcripts.
- Explain behavior and tradeoffs in the pull request.
