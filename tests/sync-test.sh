#!/usr/bin/env bash
set -euo pipefail

source_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/pi-agent-config-sync-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/seed"
tar -C "$source_root" --exclude=.git -cf - . | tar -C "$tmp/seed" -xf -
git -C "$tmp/seed" init -q -b main
git -C "$tmp/seed" add .
git -C "$tmp/seed" -c user.name=Test -c user.email=test@example.invalid commit -qm seed
git clone -q --bare "$tmp/seed" "$tmp/remote.git"
git clone -q "$tmp/remote.git" "$tmp/client"
git clone -q "$tmp/remote.git" "$tmp/upstream"

export HOME="$tmp/home"
export PI_AGENT_DIR="$tmp/pi-agent"
export PI_WORKSPACE_ROOT="$tmp/workspace"
mkdir -p "$HOME"

"$tmp/client/bin/pi-config-restore" >/dev/null
"$tmp/client/bin/pi-config-sync" >/dev/null

printf '\nupstream test\n' >> "$tmp/upstream/README.md"
git -C "$tmp/upstream" add README.md
git -C "$tmp/upstream" -c user.name=Test -c user.email=test@example.invalid commit -qm upstream
git -C "$tmp/upstream" push -q origin main
"$tmp/client/bin/pi-config-sync" >/dev/null
[ "$(git -C "$tmp/client" rev-parse HEAD)" = "$(git -C "$tmp/upstream" rev-parse HEAD)" ]

printf 'dirty\n' >> "$tmp/client/README.md"
if "$tmp/client/bin/pi-config-sync" >"$tmp/sync.out" 2>"$tmp/sync.err"; then
  printf 'expected sync to refuse a dirty checkout\n' >&2
  exit 1
fi
grep -q 'refusing to sync a dirty checkout' "$tmp/sync.err"

printf 'sync tests passed\n'
