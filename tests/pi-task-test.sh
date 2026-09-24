#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/pi-task-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
remote="$tmp/origin.git"
seed="$tmp/seed"
checkout="$tmp/demo-repo"
fake_bin="$tmp/fake-bin"
state="$tmp/state"
mkdir -p "$fake_bin"

fail() {
  printf 'pi-task test failed: %s\n' "$1" >&2
  exit 1
}

git init --bare --initial-branch=main "$remote" >/dev/null
git init -b main "$seed" >/dev/null
printf 'one\n' > "$seed/file.txt"
git -C "$seed" add file.txt
git -C "$seed" -c user.name=Test -c user.email=test@example.invalid commit -m initial >/dev/null
git -C "$seed" remote add origin "$remote"
git -C "$seed" push -u origin main >/dev/null 2>&1
git clone "$remote" "$checkout" >/dev/null 2>&1
git -C "$checkout" remote set-head origin --auto >/dev/null 2>&1
# Change the server's default after cloning to prove the launcher does not trust stale origin/HEAD.
git -C "$seed" checkout -b trunk >/dev/null 2>&1
printf 'trunk\n' > "$seed/trunk.txt"
git -C "$seed" add trunk.txt
git -C "$seed" -c user.name=Test -c user.email=test@example.invalid commit -m trunk >/dev/null
git -C "$seed" push -u origin trunk >/dev/null 2>&1
git --git-dir="$remote" symbolic-ref HEAD refs/heads/trunk

cat > "$fake_bin/pi" <<'FAKE_PI'
#!/usr/bin/env bash
printf '%s\n' "$PWD" > "$PI_TASK_TEST_CWD"
printf '%s\n' "$*" > "$PI_TASK_TEST_ARGS"
FAKE_PI
chmod +x "$fake_bin/pi"
export PATH="$fake_bin:$PATH"
export PI_TASK_STATE_DIR="$state"
export PI_TASK_TEST_CWD="$tmp/pi-cwd"
export PI_TASK_TEST_ARGS="$tmp/pi-args"

# A new task creates a unique sibling worktree and starts Pi there.
output=$(cd "$checkout" && "$repo_root/bin/pi-task" GOO-1234-alert-context -- --model test/mock)
task_id=$(printf '%s\n' "$output" | sed -n 's/^  task id: //p')
branch=$(printf '%s\n' "$output" | sed -n 's/^  branch: //p')
worktree=$(printf '%s\n' "$output" | sed -n 's/^  worktree: //p')
base_sha=$(git -C "$checkout" rev-parse origin/trunk)
[ -n "$task_id" ] || fail 'new task did not report an id'
[ -n "$worktree" ] && [ -d "$worktree" ] || fail 'new task worktree was not created'
[ "$(git -C "$worktree" branch --show-current)" = "$branch" ] || fail 'new task branch mismatch'
[ "$branch" = "pi/goo-1234-alert-context-${branch##*-}" ] || fail 'branch slug was not normalized or unique'
[ "$(git -C "$worktree" rev-parse HEAD)" = "$base_sha" ] || fail 'task did not start at the current remote default'
[ "$(cat "$PI_TASK_TEST_CWD")" = "$worktree" ] || fail 'Pi did not start in the new worktree'
case $(cat "$PI_TASK_TEST_ARGS") in
  "--session-id $task_id --model test/mock") ;;
  *) fail 'Pi session id or forwarded arguments are wrong' ;;
esac
[ "$(git -C "$checkout" branch --show-current)" = main ] || fail 'shared checkout branch changed'
[ "$(git -C "$checkout" rev-parse HEAD)" = "$(git -C "$checkout" rev-parse main)" ] || fail 'shared checkout HEAD changed'
[ -z "$(git -C "$checkout" status --porcelain=v1 -uall)" ] || fail 'shared checkout was dirtied'

record="$state/$task_id.json"
[ -f "$record" ] || fail 'task-start record was not persisted'
node -e '
const record = require(process.argv[1]);
for (const key of ["owner", "repoPath", "worktreePath", "branch", "headAtStart", "defaultRef", "defaultSha", "fetchedAt", "createdAt", "sessionId"]) {
  if (!record[key]) throw new Error(`missing record field ${key}`);
}
if (record.taskId !== record.sessionId) throw new Error("session id does not match task id");
if (record.defaultRef !== "origin/trunk") throw new Error("launcher trusted a stale origin/HEAD ref");
' "$record"

# Continuing the recorded task reuses the same worktree and session; it creates no branch.
count_before=$(git -C "$checkout" worktree list --porcelain | grep -c '^worktree ')
(cd "$checkout" && "$repo_root/bin/pi-task" --continue "$task_id") >/dev/null
count_after=$(git -C "$checkout" worktree list --porcelain | grep -c '^worktree ')
[ "$count_before" -eq "$count_after" ] || fail 'continue created or removed a worktree'
[ "$(cat "$PI_TASK_TEST_CWD")" = "$worktree" ] || fail 'continue used the wrong worktree'
[ "$(cat "$PI_TASK_TEST_ARGS")" = "--session-id $task_id" ] || fail 'continue did not reuse the same Pi session'
grep -q "^$task_id[[:space:]]paused[[:space:]]$branch[[:space:]]$worktree" <("$repo_root/bin/pi-task" --list) || fail 'task list omitted the recorded task'

# A later task bases itself on the newly fetched default, without disturbing dirty source files.
printf 'two\n' >> "$seed/file.txt"
git -C "$seed" add file.txt
git -C "$seed" -c user.name=Test -c user.email=test@example.invalid commit -m second >/dev/null
git -C "$seed" push origin trunk >/dev/null 2>&1
printf 'keep me\n' > "$checkout/local-notes.txt"
output2=$(cd "$checkout" && "$repo_root/bin/pi-task" second-task)
worktree2=$(printf '%s\n' "$output2" | sed -n 's/^  worktree: //p')
new_base=$(git -C "$checkout" rev-parse origin/trunk)
[ "$(git -C "$worktree2" rev-parse HEAD)" = "$new_base" ] || fail 'second task did not use the refreshed remote default SHA'
[ "$(cat "$checkout/local-notes.txt")" = 'keep me' ] || fail 'dirty source file was altered'

# Invalid use is fail-closed.
if (cd "$tmp" && "$repo_root/bin/pi-task" invalid) >"$tmp/not-repo.out" 2>&1; then
  fail 'launcher succeeded outside a Git repository'
fi
if "$repo_root/bin/pi-task" --continue does-not-exist >"$tmp/missing-task.out" 2>&1; then
  fail 'continue succeeded with an unknown task id'
fi

printf 'pi-task tests passed\n'
