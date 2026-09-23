---
name: writing-for-agents
description: Write concise agent-facing instructions with clear triggers, ownership, and completion criteria. Invoke explicitly with Pi's `/skill:<name>` syntax.
disable-model-invocation: true
---

# Writing for agents

Use for one named agent-facing instruction set. This skill authorizes documentation
changes only, not product behavior or workflow execution.

Keep one source of truth. State the trigger, scope, authority boundary, inputs,
observable completion criteria, and only the mechanics unique to the instruction.
Prefer pointers and progressive disclosure over copied global rules. Remove duplicate,
stale, and no-op instructions; keep examples short and literal. Finish with the
revised artifact, the ambiguity or duplication removed, and any unresolved authority
decision.
