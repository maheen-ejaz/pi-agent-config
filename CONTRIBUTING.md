# Contributing

Thanks for helping improve this Pi configuration.

## Propose a change

1. Start from freshly fetched `origin/main` in a dedicated task worktree and branch.
2. Keep the change focused and preserve unrelated work.
3. Update human documentation when behavior or ownership changes.
4. Run the local checks from `README.md`.
5. Review for secrets, personal paths, private infrastructure, and session data.
6. Open a pull request explaining the problem, approach, checks, tradeoffs, and rollback.

Do not edit the shared `main` checkout directly. Do not add GitHub Actions workflows, credentials, machine-bound MCP configuration, or automatic background synchronization.

## Style

Write instructions for an unfamiliar reader. Define Pi-specific terms, use exact paths and commands, distinguish required policy from examples, and keep one source of truth for each rule.

By contributing, you agree that your contribution is licensed under the repository's MIT License.
