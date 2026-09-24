---
name: linear-ticket-delivery
description: Deliver one explicitly identified Linear ticket through implementation, merge, release, and production validation. Invoke explicitly with `/skill:linear-ticket-delivery <ticket>`.
disable-model-invocation: true
---

# Linear ticket delivery

## Pi runtime

Invoke this skill explicitly with `/skill:linear-ticket-delivery <ticket>`. Global policy allows subagent and workflow use only during this explicitly invoked delivery workflow. The installed `@davecodes/pi-subagents` package uses the `subagent` API (`agent` + `task`), not the legacy `Agent` / `SubagentWorkflow` API. Read the bundled `pi-subagents` skill for current orchestration guidance; do not use its proactive-delegation guidance outside this workflow. Prefer `async: true` so the parent can continue useful work; use a foreground run only when the parent must block. Do not use the package's `worktree: true` mode: it force-removes child worktrees and branches without the preservation, ownership, and approval checks required by global policy. Keep a single writer in the task-owned worktree; any parallel writer needs separately approved safe isolation.

Deliver one explicitly identified Linear ticket through verified completion. Require
the ticket key and target repository, or enough context to identify both.

## Intake

Read the ticket, repository context, and governing instructions; use them as the
scope and acceptance criteria.

When running in BB (`BB_THREAD_ID` and `bb` are available), rename the current
thread after reading the ticket. Use its numeric suffix, ` - `, and an exactly
three-word, goal-bearing summary drawn from the title, description, and acceptance
criteria. Choose words that convey the intended action and outcome; do not simply
truncate the title. Format the title as `<ticket-number> - <three-word summary>`;
run `bb thread update --self --title "<ticket-number> - <three-word summary>"`,
then confirm it with `bb thread show --json`. Outside BB, skip this step.

Invoke the `grilling` skill only when missing clarity blocks completion or a material product
or implementation decision needs admin input.

Create or continue the matching ticket goal from those criteria and the global
`COMPLETE` definition; never replace an unrelated goal or set a budget unprompted.

## Delegation

After reading the ticket and repository context, decide whether its acceptance
criteria contain independent, bounded work that can run concurrently. Use
subagents only when parallel execution will materially shorten delivery, an
isolated investigation will keep substantial evidence out of the primary
context, or an independent review is required. Handle small, sequential, or
tightly coupled work directly. Notice useful adjacent tasks, but do not silently
expand the ticket: propose out-of-scope work and wait for approval before
launching it.

Give each subagent one non-overlapping outcome, the minimum context it needs,
and clear boundaries for files and side effects. Do not let multiple agents edit
the same area concurrently. Use a background run when the parent can continue;
do not launch parallel writers until safe isolation outside the package's worktree
mode is explicitly approved. Continue useful primary-agent work
while delegated work runs, then integrate only a concise handoff containing
findings, evidence, changed paths, checks, and any unresolved issue. Stop
delegating when the coordination cost or duplicated context would exceed the
likely benefit.

Use the package's `subagent` tool with `agent` and `task`; use `async: true` for
background execution. Parallel read-only tasks may use `tasks: [...]` without
worktree isolation; do not use `worktree: true` or concurrent writers in one
worktree. Use `subagent({ action: "status", ... })` to inspect runs,
`send_message` to steer a specific child, and `wait` when results are needed.
Follow the bundled `pi-subagents` skill for exact syntax while honoring the
worktree restriction above. Keep ordinary work subagent-free. Do not use a
workflow or child agent for unrelated work, and do not delegate credential
access or destructive Linear deletion.

## Delivery

Follow the global delivery workflow. Invocation authorizes the documented production
rollout for this ticket.

For a failed approach, record the observation, hypothesis, smallest safe test, and
outcome before choosing a materially distinct next approach.

Use the `computer-use` skill only when a GUI is necessary; use the `deep-research` skill only for
substantial unresolved technical uncertainty after local evidence and primary docs.

Send concise progress updates at meaningful checkpoints; continue unless admin input
is required.

## Completion

Before completion or a blocker, run the repository's fresh, non-destructive task-close
classification when available. Revalidate the exact repository/worktree identity,
branch, HEAD, freshly fetched default SHA, dirty and in-progress Git state, owner
release, and push/PR/merge evidence. Record one disposition in the Linear update and
local task record: `active`, `preserve-dirty`, `preserve-unmerged`,
`blocked-ownership`, or `ready-for-admin-retirement-review`. Unknown or conflicting
evidence preserves the worktree and names the blocker.

Never turn the classification into implicit cleanup. Committing unexpected residue,
abandoning changes, worktree removal, and local or remote branch deletion require
immediate structured admin approval naming the exact path, branch/ref, and HEAD, then
fresh revalidation before execution.

Post one value-free Linear update with the distinct approaches, outcomes, decisive
evidence, close disposition, and remaining blocker if any. Once global `COMPLETE`
requirements are met, close the ticket, complete the goal, and report the global status
card.
