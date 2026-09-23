---
name: linear-ticket-delivery
description: Deliver one explicitly identified Linear ticket through implementation, merge, release, and production validation. Invoke explicitly with `/skill:linear-ticket-delivery <ticket>`.
disable-model-invocation: true
---

# Linear ticket delivery

## Pi runtime

Invoke this skill explicitly with `/skill:linear-ticket-delivery <ticket>`. Pi keeps the subagent and workflow tools disabled by default and enables them for this session only after this skill is invoked. Do not use those tools outside this delivery workflow; start a new session for unrelated work.

Deliver one explicitly identified Linear ticket through verified completion. Require
the ticket key and target repository, or enough context to identify both.

## Intake

Read the ticket, repository context, and governing instructions; use them as the
scope and acceptance criteria.

When running in BB (`BB_THREAD_ID` and `bb` are available), rename the current
thread after reading the ticket. Use its numeric suffix, ` - `, and an exactly
three-word, goal-bearing summary drawn from the title, description, and acceptance
criteria. Choose words that convey the intended action and outcome; do not simply
truncate the title. For `GOO-1344`, use `1344 - Detect Sensitive PII`; run
`bb thread update --self --title "1344 - Detect Sensitive PII"`, then confirm it
with `bb thread show --json`. Outside BB, skip this step.

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
tightly coupled work directly.

Give each subagent one non-overlapping outcome, the minimum context it needs,
and clear boundaries for files and side effects. Do not let multiple agents edit
the same area concurrently. Continue useful primary-agent work while delegated
work runs, then integrate only a concise handoff containing findings, evidence,
changed paths, checks, and any unresolved issue. Stop delegating when the
coordination cost or duplicated context would exceed the likely benefit.

Use Pi's `Agent`, `SubagentWorkflow`, `get_subagent_result`, and `steer_subagent` tools only after this skill was explicitly invoked. Keep ordinary work subagent-free. Do not use a workflow or child agent for unrelated work, and do not delegate credential access or destructive Linear deletion.

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

Before completion or a blocker, post one value-free Linear update with the distinct
approaches, outcomes, and decisive evidence or remaining blocker. Once global
`COMPLETE` requirements are met, close the ticket, complete the goal, and report the
global status card.
