# Agentbrowser OpenCode Design

**Goal:** Configure OpenCode to expose browser automation tools under the MCP server name `agentbrowser`.

**Context:** OpenCode is already installed through the Nix flake in `modules/packages/unstable.nix`. The current global OpenCode config at `/home/yvesd/.config/opencode/opencode.json` only enables the `superpowers` plugin. No MCP servers are declared in the repository.

**Approach:** Manage OpenCode's global config declaratively from the existing Home Manager profile. The profile writes `~/.config/opencode/opencode.json` with the existing `superpowers` plugin preserved and an MCP server named `agentbrowser` configured to launch Playwright MCP with Nix-provided `npx`, Nix-provided Chromium, and a PATH that includes Nix's Node.js before the existing runtime PATH.

**Architecture:**
- `homeManager/home.nix` owns OpenCode user configuration through `home.file`.
- The Playwright MCP command uses `lib.getExe' pkgs.nodejs "npx"` and `lib.getExe pkgs.chromium` so the browser runtime is reproducible.
- The MCP environment prepends `lib.makeBinPath [pkgs.nodejs]` to `{env:PATH}` so package binaries with `#!/usr/bin/env node` can start while npm still finds system tools such as `sh`.

**Runtime Behavior:** OpenCode registers MCP tools with the server name as the prefix, so the server name `agentbrowser` makes browser tools available as `agentbrowser_*`. Playwright MCP launches Chromium directly and does not require a browser extension connection.

**Out of Scope:** This change does not change the default browser, add `opencode-browser`, or modify system package lists. The `opencode-browser` plugin is intentionally omitted because its prefix-specific behavior targets `browsermcp_*`, while this setup intentionally uses `agentbrowser_*`.

**Validation:** Parse all Nix files and dry-run the Home Manager activation package. After applying the Home Manager profile, validate with `opencode debug config` and `opencode mcp list`.
