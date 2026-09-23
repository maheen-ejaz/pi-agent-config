#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/pi-agent-config-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export PI_AGENT_DIR="$tmp/pi-agent"
export PI_WORKSPACE_ROOT="$tmp/workspace"
mkdir -p "$HOME"

"$repo_root/bin/pi-config-restore" >/dev/null
"$repo_root/bin/pi-config-check" >/dev/null
"$repo_root/bin/pi-config-restore" >/dev/null

expected_skills=$(grep -cve '^$' "$repo_root/skills/catalog.txt")
for skill_name in $(cat "$repo_root/skills/catalog.txt"); do
  [ -L "$PI_AGENT_DIR/skills/$skill_name" ]
done
actual_links=$(find "$PI_AGENT_DIR/skills" -mindepth 1 -maxdepth 1 -type l | wc -l | tr -d ' ')
[ "$actual_links" -eq "$((expected_skills + 1))" ] # catalog plus README link

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

printf 'restore tests passed\n'
