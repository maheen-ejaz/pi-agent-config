# Pi-owned skills

Every installed directory in this tree links to the independent Pi copy tracked by `pi-agent-config`. `skills/catalog.txt` in that repository is the installation manifest.

Pi discovers `~/.pi/agent/skills` before `~/.agents/skills`, so Pi copies win same-name collisions. `pi-config-check` verifies that the complete catalog is present and linked to the expected source. Never delete a Pi copy merely to suppress a collision warning: doing so can expose another harness's workflow to Pi.
