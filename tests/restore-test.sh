#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/pi-agent-config-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export PI_AGENT_DIR="$tmp/pi-agent"
export PI_WORKSPACE_ROOT="$tmp/workspace"
export PI_BIN_DIR="$tmp/local-bin"
mkdir -p "$HOME"

mkdir -p "$HOME/.agents/skills/github-issue-delivery"
printf '# Fixture shared issue-delivery skill\n' > "$HOME/.agents/skills/github-issue-delivery/SKILL.md"
if "$repo_root/bin/pi-config-restore" >"$tmp/missing-shared.out" 2>"$tmp/missing-shared.err"; then
  printf 'expected restore to fail when a canonical shared skill is missing\n' >&2
  exit 1
fi
grep -q 'canonical shared skill is missing SKILL.md' "$tmp/missing-shared.err"
[ ! -e "$PI_AGENT_DIR/AGENTS.md" ]

mkdir -p "$HOME/.agents/skills/github-issue-operations"
printf '# Fixture shared issue-operations skill\n' > "$HOME/.agents/skills/github-issue-operations/SKILL.md"

"$repo_root/bin/pi-config-restore" >/dev/null
"$repo_root/bin/pi-config-check" >/dev/null
"$repo_root/bin/pi-config-restore" >/dev/null

expected_skills=$(grep -cve '^$' "$repo_root/skills/catalog.txt")
for skill_name in $(cat "$repo_root/skills/catalog.txt"); do
  [ -L "$PI_AGENT_DIR/skills/$skill_name" ]
done
for skill_name in github-issue-delivery github-issue-operations; do
  [ -L "$PI_AGENT_DIR/skills/$skill_name" ]
  [ "$(readlink "$PI_AGENT_DIR/skills/$skill_name")" = "$HOME/.agents/skills/$skill_name" ]
done
actual_links=$(find "$PI_AGENT_DIR/skills" -mindepth 1 -maxdepth 1 -type l | wc -l | tr -d ' ')
[ "$actual_links" -eq "$((expected_skills + 3))" ] # owned catalog, two shared bridges, and README link
[ -L "$PI_BIN_DIR/pi-task" ]
[ "$(readlink "$PI_BIN_DIR/pi-task")" = "$repo_root/bin/pi-task" ]

rm "$PI_AGENT_DIR/extensions/tool-profiles.ts"
printf 'preserve me\n' > "$PI_AGENT_DIR/extensions/tool-profiles.ts"
if "$repo_root/bin/pi-config-restore" >"$tmp/restore.out" 2>"$tmp/restore.err"; then
  printf 'expected restore to refuse an existing regular file\n' >&2
  exit 1
fi
grep -q 'refusing to overwrite existing path' "$tmp/restore.err"
grep -q '^preserve me$' "$PI_AGENT_DIR/extensions/tool-profiles.ts"

rm "$PI_AGENT_DIR/extensions/tool-profiles.ts"
"$repo_root/bin/pi-config-restore" >/dev/null
"$repo_root/bin/pi-config-check" >/dev/null

rm "$PI_BIN_DIR/pi-task"
printf 'preserve executable\n' > "$PI_BIN_DIR/pi-task"
if "$repo_root/bin/pi-config-restore" >"$tmp/bin-restore.out" 2>"$tmp/bin-restore.err"; then
  printf 'expected restore to refuse an existing pi-task path\n' >&2
  exit 1
fi
grep -q 'refusing to overwrite existing path' "$tmp/bin-restore.err"
grep -q '^preserve executable$' "$PI_BIN_DIR/pi-task"

# Existing installations can keep canonical governance/runtime pointers and add
# only the shared GitHub issue skills to Pi's otherwise empty user skill dir.
shared_home="$tmp/shared-home"
canonical_pi="$tmp/canonical-pi"
export HOME="$shared_home"
export PI_AGENT_DIR="$tmp/shared-pi-agent"
export PI_WORKSPACE_ROOT="$tmp/shared-workspace"
export PI_BIN_DIR="$tmp/shared-bin"
mkdir -p "$HOME/.agents/workspace" "$PI_AGENT_DIR/extensions" "$PI_AGENT_DIR/skills" \
  "$PI_WORKSPACE_ROOT" "$PI_BIN_DIR" "$canonical_pi/extensions" "$canonical_pi/bin"
printf '# Canonical shared guidance\n' > "$HOME/.agents/AGENTS.md"
printf '# Canonical workspace guidance\n' > "$HOME/.agents/workspace/Developer.AGENTS.md"
printf '// Canonical Pi extension\n' > "$canonical_pi/extensions/tool-profiles.ts"
printf '#!/bin/sh\nexit 0\n' > "$canonical_pi/bin/pi-task"
chmod +x "$canonical_pi/bin/pi-task"
ln -s "$HOME/.agents/AGENTS.md" "$PI_AGENT_DIR/AGENTS.md"
ln -s "$HOME/.agents/workspace/Developer.AGENTS.md" "$PI_WORKSPACE_ROOT/AGENTS.md"
ln -s "$canonical_pi/extensions/tool-profiles.ts" "$PI_AGENT_DIR/extensions/tool-profiles.ts"
ln -s "$canonical_pi/bin/pi-task" "$PI_BIN_DIR/pi-task"
mkdir -p "$HOME/.agents/skills/github-issue-delivery"
printf '# Fixture shared issue-delivery skill\n' > "$HOME/.agents/skills/github-issue-delivery/SKILL.md"

if "$repo_root/bin/pi-config-restore" --shared-skills-only extra >"$tmp/shared-args.out" 2>"$tmp/shared-args.err"; then
  printf 'expected shared-only restore to reject extra arguments\n' >&2
  exit 1
fi
grep -q 'usage:' "$tmp/shared-args.err"
[ -z "$(find "$PI_AGENT_DIR/skills" -mindepth 1 -maxdepth 1 -type l -print -quit)" ]
if "$repo_root/bin/pi-config-check" --shared-skills-only --source-only >"$tmp/shared-check-args.out" 2>"$tmp/shared-check-args.err"; then
  printf 'expected shared-only check to reject combined modes\n' >&2
  exit 1
fi
grep -q 'usage:' "$tmp/shared-check-args.err"

if "$repo_root/bin/pi-config-restore" --shared-skills-only >"$tmp/shared-missing.out" 2>"$tmp/shared-missing.err"; then
  printf 'expected shared-only restore to fail when a canonical skill is missing\n' >&2
  exit 1
fi
grep -q 'canonical shared skill is missing SKILL.md' "$tmp/shared-missing.err"
[ "$(readlink "$PI_AGENT_DIR/AGENTS.md")" = "$HOME/.agents/AGENTS.md" ]
[ "$(readlink "$PI_WORKSPACE_ROOT/AGENTS.md")" = "$HOME/.agents/workspace/Developer.AGENTS.md" ]
[ "$(readlink "$PI_AGENT_DIR/extensions/tool-profiles.ts")" = "$canonical_pi/extensions/tool-profiles.ts" ]
[ "$(readlink "$PI_BIN_DIR/pi-task")" = "$canonical_pi/bin/pi-task" ]
[ -z "$(find "$PI_AGENT_DIR/skills" -mindepth 1 -maxdepth 1 -type l -print -quit)" ]

mkdir -p "$HOME/.agents/skills/github-issue-operations"
printf '# Fixture shared issue-operations skill\n' > "$HOME/.agents/skills/github-issue-operations/SKILL.md"
mkdir -p "$PI_AGENT_DIR/skills/github-issue-operations"
printf 'preserve shared target\n' > "$PI_AGENT_DIR/skills/github-issue-operations/marker.txt"
if "$repo_root/bin/pi-config-restore" --shared-skills-only >"$tmp/shared-target-conflict.out" 2>"$tmp/shared-target-conflict.err"; then
  printf 'expected restore to reject a conflicting second shared target\n' >&2
  exit 1
fi
grep -q 'refusing to overwrite existing path' "$tmp/shared-target-conflict.err"
[ ! -e "$PI_AGENT_DIR/skills/github-issue-delivery" ]
[ "$(cat "$PI_AGENT_DIR/skills/github-issue-operations/marker.txt")" = 'preserve shared target' ]
rm -r "$PI_AGENT_DIR/skills/github-issue-operations"

"$repo_root/bin/pi-config-restore" --shared-skills-only >/dev/null
"$repo_root/bin/pi-config-check" --shared-skills-only >/dev/null
for skill_name in github-issue-delivery github-issue-operations; do
  [ "$(readlink "$PI_AGENT_DIR/skills/$skill_name")" = "$HOME/.agents/skills/$skill_name" ]
done
[ "$(find "$PI_AGENT_DIR/skills" -mindepth 1 -maxdepth 1 -type l | wc -l | tr -d ' ')" -eq 2 ]
[ ! -e "$PI_AGENT_DIR/skills/README.md" ]
[ ! -e "$PI_AGENT_DIR/skills/bb-cli" ]
[ "$(readlink "$PI_AGENT_DIR/AGENTS.md")" = "$HOME/.agents/AGENTS.md" ]
[ "$(readlink "$PI_WORKSPACE_ROOT/AGENTS.md")" = "$HOME/.agents/workspace/Developer.AGENTS.md" ]
[ "$(readlink "$PI_AGENT_DIR/extensions/tool-profiles.ts")" = "$canonical_pi/extensions/tool-profiles.ts" ]
[ "$(readlink "$PI_BIN_DIR/pi-task")" = "$canonical_pi/bin/pi-task" ]

printf 'restore tests passed\n'
