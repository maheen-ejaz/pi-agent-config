---
name: main-sync
description: Inspect and safely align one Git repository's canonical main checkout with its fetched origin default branch. Invoke explicitly with `/skill:main-sync [repository path]`.
disable-model-invocation: true
---

# Main checkout health and sync

Use only when explicitly invoked as `/skill:main-sync [repository path]`. If no path is supplied, use the current working directory. Operate on one repository per invocation; do not scan the workspace or guess a repository path.

## Rules

- Diagnose before changing anything. Fetching remote-tracking metadata with `git fetch --no-prune origin` is allowed for this explicit sync request; never prune.
- Identify the repository root, then resolve the *live* default branch and HEAD SHA with `git ls-remote --symref origin HEAD`; do not trust a possibly stale local `origin/HEAD` alias. Fetch the exact advertised branch into its `refs/remotes/origin/<branch>` ref and verify that fetched SHA still matches the live remote HEAD before presenting a change. If the branch or SHA keeps moving, stop and report it. Do not print the remote URL.
- If the live default cannot be resolved unambiguously, stop and ask the user how to resolve that; never assume `main` or `master`.
- Identify the worktree actually checked out on the live default branch, its `HEAD`, upstream, complete porcelain status including untracked files, and any merge/rebase/cherry-pick/revert in progress.
- If the canonical checkout is clean and exactly equals its fetched default ref, report that no action is needed.
- If it is clean and strictly behind only, use the structured `ask_user_question` tool to offer: (1) fast-forward this exact checkout to the displayed fetched SHA, (2) inspect incoming commits first, or (3) leave it unchanged. Recommend the fast-forward. After approval, fetch and resolve the live default again; if its branch or SHA changed, ask again. Otherwise revalidate the exact path, branch, `HEAD`, clean status, and no in-progress operation immediately before `git merge --ff-only`.
- If dirty, never stash, reset, checkout, clean, or overwrite. Show changed paths and use `ask_user_question` to offer inspecting the diff to form a preservation plan (recommended), or leaving it unchanged. Do not offer a destructive cleanup as a resolution.
- If ahead or diverged, show the local-only and remote-only commits and offer to inspect them and propose a reconciliation plan, or preserve the checkout unchanged. Do not merge, rebase, reset, or force-align automatically.
- If the invoked directory is not the canonical default-branch worktree, identify the canonical path and offer to inspect it or leave it alone; do not switch the current checkout. Ask before any action on another exact path.
- On fetch errors, wrong branch, in-progress Git state, missing upstream, or ambiguous identity, stop and use `ask_user_question` to offer safe diagnosis or cancellation. Every question must present concrete consequences; if no safe mutation is available, the choices must remain read-only.

## Completion

After any approved fast-forward, verify that the same worktree is clean and its `HEAD` exactly equals the target SHA. Report the path, branch, old/new `HEAD`, and outcome. If approval is cancelled or checks no longer match, make no change and report why.
