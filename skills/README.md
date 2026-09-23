# Pi skill catalog

Each directory is an independent Pi-facing skill. Pi loads only names and descriptions at startup; it reads the full `SKILL.md` when a task invokes or matches the skill.

| Skill | Activation | Purpose |
|---|---|---|
| `bb-cli` | Explicit | Inspect and operate BB state through its CLI |
| `diagnosing-bugs` | Explicit | Diagnose difficult bugs with a reproducible evidence loop |
| `diagram-design` | Explicit | Produce branded technical and business diagrams |
| `grilling` | Explicit | Resolve one material decision through structured questions |
| `i-have-adhd` | Explicit | Adapt response structure for an ADHD reader |
| `infisical-credential-access` | Automatic when relevant | Enforce repository-declared secret access boundaries |
| `linear-ticket-delivery` | Explicit | Deliver one Linear ticket through verified completion |
| `linear-ticket-operations` | Automatic for Linear work | Standardize all Linear reads and mutations through `linear-direct` |
| `repo-audit` | Explicit | Run bounded daily, weekly, or report-mode repository audits |
| `resolving-merge-conflicts` | Explicit | Resolve real Git conflicts while preserving both intents |
| `tdd` | Explicit | Run strict red-green-refactor development |
| `wayfinder` | Explicit | Map a large ambiguous effort without implementing it |
| `writing-for-agents` | Explicit | Write concise agent-facing instruction sets |

Explicit skills declare `disable-model-invocation: true` and are invoked with:

```text
/skill:<name> [arguments]
```

The complete install list lives in [`catalog.txt`](catalog.txt). Restore and check scripts use that manifest rather than discovering arbitrary directories.

See [`SOURCES.md`](SOURCES.md) for initial provenance. These copies now evolve independently from Codex and Claude Code versions.
