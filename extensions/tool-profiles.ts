import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { StringEnum } from "@earendil-works/pi-ai";
import { Type } from "typebox";

const PROFILE_NAMES = ["web", "browser", "linear", "core"] as const;
type ProfileName = (typeof PROFILE_NAMES)[number];

const WEB_TOOLS = new Set(["web_search", "source_check", "fetch_content", "get_search_content"]);

function profileForTool(name: string): Exclude<ProfileName, "core"> | undefined {
  if (WEB_TOOLS.has(name)) return "web";
  if (name.startsWith("browser_")) return "browser";
  if (name === "mcp" || name === "mcpScript" || name.startsWith("linear-direct_")) return "linear";
  return undefined;
}

export default function toolProfiles(pi: ExtensionAPI): void {
  const enabled = new Set<Exclude<ProfileName, "core">>();

  function sync(): void {
    const active = pi.getActiveTools();
    const next = active.filter((name) => {
      const profile = profileForTool(name);
      return !profile || enabled.has(profile);
    });

    const registered = pi.getAllTools().map((tool) => tool.name);
    for (const name of registered) {
      const profile = profileForTool(name);
      if (profile && enabled.has(profile) && !next.includes(name)) next.push(name);
    }
    if (!next.includes("activate_tool_profile") && registered.includes("activate_tool_profile")) {
      next.push("activate_tool_profile");
    }
    if (next.length !== active.length || next.some((name, index) => name !== active[index])) {
      pi.setActiveTools(next);
    }
  }

  function apply(profile: ProfileName): string {
    if (profile === "core") {
      enabled.clear();
      sync();
      return "Restored the lean core tool set.";
    }
    enabled.add(profile);
    sync();
    const loaded = pi.getActiveTools().filter((name) => profileForTool(name) === profile);
    return loaded.length > 0
      ? `Activated ${profile} tools: ${loaded.join(", ")}`
      : `No registered ${profile} tools were found.`;
  }

  pi.registerTool({
    name: "activate_tool_profile",
    label: "Activate tool profile",
    description: "Activate registered web, browser, or Linear tools for the current focused session, or restore the lean core set.",
    promptSnippet: "Activate specialized web, browser, or Linear tools only when the task needs them",
    promptGuidelines: [
      "Use activate_tool_profile before work that needs web, browser automation, or Linear tools that are not currently active.",
    ],
    parameters: Type.Object({
      profile: StringEnum(PROFILE_NAMES, { description: "Specialized profile to activate, or core to hide specialized tools." }),
    }),
    async execute(_toolCallId, params) {
      const text = apply(params.profile);
      return { content: [{ type: "text", text }], details: { profile: params.profile, active: pi.getActiveTools() } };
    },
  });

  pi.registerCommand("tool-profile", {
    description: "Activate web, browser, Linear, or lean core tools",
    handler: async (args, ctx) => {
      const profile = args.trim().toLowerCase() as ProfileName;
      if (!PROFILE_NAMES.includes(profile)) {
        ctx.ui.notify("Usage: /tool-profile web|browser|linear|core", "warning");
        return;
      }
      ctx.ui.notify(apply(profile), "info");
    },
  });

  pi.on("session_start", () => {
    enabled.clear();
    sync();
  });

  pi.on("input", (event) => {
    if (event.source !== "extension" && /^\/skill:linear-ticket-(?:delivery|operations)\b/.test(event.text ?? "")) {
      enabled.add("linear");
    }
    sync();
  });

  pi.on("before_agent_start", () => sync());

  // Active-set filtering is the context optimization; this guard also prevents a
  // stale provider declaration from bypassing the selected profile.
  pi.on("tool_call", (event) => {
    const profile = profileForTool(event.toolName);
    if (!profile || enabled.has(profile)) return;
    return {
      block: true,
      reason: `Tool ${event.toolName} is inactive. Call activate_tool_profile with profile=${profile} first.`,
    };
  });
}
