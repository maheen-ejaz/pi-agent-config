---
name: linear-ticket-operations
description: Automatically standardize every Linear issue read, search, create, edit, comment, metadata, relation, archive, unarchive, or delete operation with project-style content and post-save verification.
---

# Linear ticket operations

Use this skill automatically for every Linear interaction. It is Pi's mandatory Linear workflow; the user does not need to invoke it.

## Access

- Use the globally configured `linear-direct` MCP server through Pi's MCP tools.
- Do not use browser automation, the old Linear CLI, or a second Linear integration.
- Prefer high-level Linear tools. Use the read-only GraphQL query tool only when a required read is not covered. Use raw GraphQL mutations only when no high-level mutation exists and the operation is otherwise authorized.
- The MCP server handles credentials through the tracked Infisical capability and fails closed when its checkout or credential contract is unsafe.

## Authorization

- Linear actions within the active user task are pre-authorized: search, deduplication, creation, editing, assignment, commenting, labels, projects, status, relations, closing, reopening, archiving, and unarchiving.
- Deleting a Linear ticket always requires explicit user confirmation immediately before the delete call. Confirm the exact identifier and whether permanent deletion is requested. Never delete by title similarity.
- After every mutation, read the affected object back and report the saved result. Do not ask for confirmation for non-delete mutations.

## Before changing an issue

1. Resolve the exact issue, team, project, and relevant metadata.
2. Inspect the current issue plus two or three recent issues in the same project when creating or substantially rewriting a ticket. Learn style and metadata conventions; do not copy their facts.
3. Search for likely duplicates before creating. If candidates exist, report them and only create when the task authorizes related duplicates.
4. Draft the smallest complete ticket with confirmed evidence separate from hypotheses.

Use an action-oriented title. Include only relevant sections, normally:

- Problem
- Product rule or current contract, if relevant
- Observed evidence
- Reproduction
- Scope or investigation plan
- Acceptance criteria
- Boundaries
- Checks already run

## Writing and metadata

- Use the Linear API's Markdown description field. Preserve real headings, lists, code spans, and links; do not convert descriptions to browser-only HTML.
- Set the intended project, status, priority, assignee, and labels using resolved IDs.
- Preserve unspecified metadata on edits.
- Minimize PII. Never paste secrets, tokens, raw logs, government-document evidence, or unnecessary applicant data.

## Verification

Reload the issue after saving and verify:

- URL and issue identifier;
- title, project, status, priority, assignee, and labels;
- description headings, lists, inline code, and links;
- relations and archive/trash state when applicable;
- no accidental metadata loss.

For delete, resolve the exact target, request confirmation, inspect relevant comments and relations first, then report the deletion result. For archive/unarchive, verify the resulting archive state; these do not require confirmation.

## Handoff

Report the issue URL/identifier, metadata changes, description and acceptance-criteria changes, relations, checks performed, and delivery/release owner. Keep ticket operations separate from code changes and production rollout.
