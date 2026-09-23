# Troubleshooting

## Restore refuses an existing path

This is intentional. Compare the existing file with the tracked source, preserve any unique content, then remove or relocate it deliberately before rerunning restore. The script never decides ownership for you.

## Check reports a wrong symlink

The clone may have moved or another tool may own the target. Inspect with `readlink <path>`. If the repository should remain authoritative, remove only that exact stale link and rerun restore from the intended clone.

## Sync refuses a dirty checkout

Commit intended work on a task branch/worktree or preserve it for its owner. Do not stash, reset, or discard unknown changes merely to make sync pass.

## Sync reports divergence

Local `main` contains commits not represented by `origin/main`. Review the graph and move intentional work through a branch and pull request. Sync never rebases, force-resets, or pushes.

## Pi reports duplicate skill names

Pi also scans `~/.agents/skills`. The Pi copy under `~/.pi/agent/skills` should win. Run `bin/pi-config-check` to confirm every catalogued Pi copy is installed. Do not delete Pi skills simply to remove the warning.

## A configuration change is not visible

Run `/reload` for resources and instructions, or `/new` for a clean session. Existing sessions preserve earlier system and tool checkpoints in their history.

## Specialized tools are unavailable

Use `/tool-profile web`, `/tool-profile browser`, or `/tool-profile linear`, or let Pi call `activate_tool_profile`. Use `/tool-profile core` to hide specialized schemas again.

## Linear reports a runtime revision failure

The configured `linear-direct` launcher is fail-closed when its credential/runtime checkout is unsafe. Do not bypass it or switch to browser automation. Repair the owning checkout through its documented lifecycle, then retry the same Linear operation.
