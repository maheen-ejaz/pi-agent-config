# Pi-owned skills

Pi discovers this tree before `~/.agents/skills`; the first same-named skill wins. This installation keeps only two Pi-specific Linear adapters here:

- `linear-ticket-operations` exclusively requires the global `linear-direct` MCP path.
- `linear-ticket-delivery` owns Pi delegation and explicit `/skill:` invocation.

Shared skills remain owned by the separate cross-harness `agents-config` repository. The two Linear name collisions are intentional compatibility variants. Never remove the Pi winner while a legacy browser-oriented cross-harness copy retains the same name.
