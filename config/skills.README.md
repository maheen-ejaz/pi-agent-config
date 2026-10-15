# Pi-owned skills

Pi-owned skill directories link to independent copies tracked by `pi-agent-config`; `skills/catalog.txt` is their installation manifest. The two canonical shared GitHub issue skills are not copied here: `config/shared-skills.txt` allowlists symlinks from `~/.agents/skills` into Pi's user skills directory. Use `pi-config-restore --shared-skills-only` and `pi-config-check --shared-skills-only` when another canonical Pi setup owns the other links.

Pi's maintained launcher disables general skill discovery. `pi-config-check` verifies the Pi-owned catalog, the separate shared-skill allowlist, exact installed symlink targets, and that names do not collide. Restore does not copy shared skill contents or install any other `~/.agents/skills` directories.
