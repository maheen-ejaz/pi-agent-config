#!/usr/bin/env bash
set -euo pipefail

source_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/pi-agent-config-catalog-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
fixture="$tmp/repo"
mkdir -p "$fixture/bin" "$fixture/skills"
cp "$source_root/bin/pi-config-check" "$fixture/bin/"
cp "$source_root/bin/pi-config-restore" "$fixture/bin/"
cp "$source_root/bin/pi-task" "$fixture/bin/"
chmod +x "$fixture/bin/pi-task"
cp "$source_root/.gitignore" "$fixture/.gitignore"
mkdir -p "$fixture/config" "$fixture/extensions"
printf '# Global guidance\n' > "$fixture/config/AGENTS.md"
printf '# Workspace guidance\n' > "$fixture/config/Developer.AGENTS.md"
printf '// extension fixture\n' > "$fixture/extensions/tool-profiles.ts"
printf '# Skills README\n' > "$fixture/config/skills.README.md"
cp "$source_root/skills/catalog.txt" "$fixture/skills/"
printf '# Skill catalog\n\n| Skill |\n|---|\n' > "$fixture/skills/README.md"
while IFS= read -r skill_name; do
  [ -n "$skill_name" ] || continue
  mkdir -p "$fixture/skills/$skill_name"
  cp "$source_root/skills/$skill_name/SKILL.md" "$fixture/skills/$skill_name/"
  printf '| `%s` |\n' "$skill_name" >> "$fixture/skills/README.md"
done < "$fixture/skills/catalog.txt"

git -C "$fixture" init -q -b main
git -C "$fixture" add .
git -C "$fixture" -c user.name=Test -c user.email=test@example.invalid commit -qm fixture
"$fixture/bin/pi-config-check" --source-only >/dev/null

mkdir -p "$fixture/.pi-subagents/artifacts"
printf 'runtime transcript\n' > "$fixture/.pi-subagents/artifacts/review.jsonl"
"$fixture/bin/pi-config-check" --source-only >/dev/null
git -C "$fixture" add .
if git -C "$fixture" ls-files --cached -- .pi-subagents | grep -q .; then
  printf 'ordinary staging must ignore subagent artifacts\n' >&2
  exit 1
fi
# A force-staged runtime artifact is still forbidden even when the directory is ignored.
git -C "$fixture" add -f .pi-subagents/artifacts/review.jsonl
if "$fixture/bin/pi-config-check" --source-only >"$tmp/artifact.out" 2>"$tmp/artifact.err"; then
  printf 'expected staged subagent artifact to fail validation\n' >&2
  exit 1
fi
grep -q 'subagent runtime artifacts must not be tracked by Git' "$tmp/artifact.err"
git -C "$fixture" rm -q --cached .pi-subagents/artifacts/review.jsonl
printf 'unexpected transcript\n' > "$fixture/unexpected.jsonl"
if "$fixture/bin/pi-config-check" --source-only >"$tmp/forbidden.out" 2>"$tmp/forbidden.err"; then
  printf 'expected unrelated transcript to fail validation\n' >&2
  exit 1
fi
grep -q 'forbidden machine or credential file' "$tmp/forbidden.err"
rm "$fixture/unexpected.jsonl"

# Many matches must not be lost when the scanner exits early under pipefail.
mkdir -p "$fixture/many-matches"
for i in $(seq 1 1000); do
  printf 'BEGIN PRIVATE%s\n' ' KEY' > "$fixture/many-matches/$i.txt"
done
if "$fixture/bin/pi-config-check" --source-only >"$tmp/many.out" 2>"$tmp/many.err"; then
  printf 'expected many secret-like files to fail validation\n' >&2
  exit 1
fi
grep -q 'repository contains a secret-like value' "$tmp/many.err"
rm -r "$fixture/many-matches"

cp "$fixture/skills/catalog.txt" "$tmp/catalog.original"
head -n 1 "$fixture/skills/catalog.txt" >> "$fixture/skills/catalog.txt"
if "$fixture/bin/pi-config-check" --source-only >"$tmp/duplicate.out" 2>"$tmp/duplicate.err"; then
  printf 'expected duplicate catalog entry to fail validation\n' >&2
  exit 1
fi
grep -q 'catalog, skills README, and skill directories must list each skill exactly once' "$tmp/duplicate.err"
cp "$tmp/catalog.original" "$fixture/skills/catalog.txt"

mkdir -p "$fixture/skills/unlisted"
printf '# Unlisted skill\n' > "$fixture/skills/unlisted/SKILL.md"
if "$fixture/bin/pi-config-check" --source-only >"$tmp/unlisted.out" 2>"$tmp/unlisted.err"; then
  printf 'expected unlisted skill to fail validation\n' >&2
  exit 1
fi
grep -q 'catalog, skills README, and skill directories must list each skill exactly once' "$tmp/unlisted.err"
rm -rf "$fixture/skills/unlisted"

first_skill=$(head -n 1 "$fixture/skills/catalog.txt")
git -C "$fixture" rm -q --cached "skills/$first_skill/SKILL.md"
if "$fixture/bin/pi-config-check" --source-only >"$tmp/untracked.out" 2>"$tmp/untracked.err"; then
  printf 'expected untracked skill source to fail validation\n' >&2
  exit 1
fi
grep -q 'is not tracked by Git' "$tmp/untracked.err"

printf '../../escape\n' > "$fixture/skills/catalog.txt"
export HOME="$tmp/home"
export PI_AGENT_DIR="$tmp/pi-agent"
export PI_WORKSPACE_ROOT="$tmp/workspace"
mkdir -p "$HOME"
if "$fixture/bin/pi-config-restore" >"$tmp/unsafe-restore.out" 2>"$tmp/unsafe-restore.err"; then
  printf 'expected restore to reject a path-traversal skill name\n' >&2
  exit 1
fi
grep -q 'invalid skill name in catalog' "$tmp/unsafe-restore.err"
[ ! -e "$PI_AGENT_DIR/AGENTS.md" ]
[ ! -e "$PI_AGENT_DIR/skills" ]

printf 'catalog tests passed\n'
