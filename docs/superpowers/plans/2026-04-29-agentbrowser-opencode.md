# Agentbrowser OpenCode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configure OpenCode browser automation tools under the MCP server name `agentbrowser`.

**Architecture:** Manage OpenCode's global JSON config from the existing Home Manager profile. Use the Nix store path to `npx` from `pkgs.nodejs`, use Nix-provided Chromium for the browser executable, and prepend Nix's Node.js bin directory to the MCP process PATH so package binaries with `#!/usr/bin/env node` can launch reproducibly without adding Node to global packages.

**Tech Stack:** NixOS, Home Manager, OpenCode MCP, Playwright MCP via `@playwright/mcp@0.0.71`, Chromium from nixpkgs, Node `npx` from nixpkgs.

---

### Task 1: Add OpenCode Home Manager Config

**Files:**
- Modify: `homeManager/home.nix`

- [ ] **Step 1: Add `lib` to module arguments**

Change the top of `homeManager/home.nix` to include `lib`:

```nix
{
  lib,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {
}
```

- [ ] **Step 2: Add the OpenCode config file declaration**

Change the existing empty `home.file` attribute set in `homeManager/home.nix` to this:

```nix
    file = {
      ".config/opencode/opencode.json" = {
        force = true;
        text =
          builtins.toJSON {
            "$schema" = "https://opencode.ai/config.json";
            plugin = ["superpowers@git+https://github.com/obra/superpowers.git"];
            mcp = {
              agentbrowser = {
                type = "local";
                command = [
                  (lib.getExe' pkgs.nodejs "npx")
                  "-y"
                  "@playwright/mcp@0.0.71"
                  "--executable-path"
                  (lib.getExe pkgs.chromium)
                  "--no-sandbox"
                  "--output-dir"
                  "/tmp/opencode-agentbrowser"
                ];
                environment = {
                  PATH = "${lib.makeBinPath [pkgs.nodejs]}:{env:PATH}";
                };
                enabled = true;
              };
            };
          }
          + "\n";
      };
    };
```

- [ ] **Step 3: Parse all Nix files**

Run: `nix-instantiate --parse $(rg --files -g '*.nix') >/dev/null`

Expected: exits successfully with no output.

### Task 2: Validate Home Manager Output

**Files:**
- Validate: `flake.nix`
- Validate: `homeManager/home.nix`

- [ ] **Step 1: Dry-run Home Manager activation package**

Run: `XDG_CACHE_HOME=/tmp nix build --dry-run --no-link '.#homeConfigurations.yvesd.activationPackage'`

Expected: Nix evaluates the Home Manager activation package successfully. It may print derivations that would be built or fetched.

- [ ] **Step 2: Check formatting**

Run: `alejandra --check $(rg --files -g '*.nix')`

Expected: exits successfully with no output, or prints the files that need formatting.

- [ ] **Step 3: Format if needed**

If Step 2 reports formatting changes, run: `alejandra $(rg --files -g '*.nix')`

Expected: Alejandra formats changed Nix files.

- [ ] **Step 4: Re-run parse after formatting**

Run: `nix-instantiate --parse $(rg --files -g '*.nix') >/dev/null`

Expected: exits successfully with no output.

### Task 3: Post-Activation Manual Checks

**Files:**
- Runtime target: `/home/yvesd/.config/opencode/opencode.json`

- [ ] **Step 1: Apply Home Manager outside this plan**

Run when ready: `home-manager switch --flake '.#yvesd'`

Expected: Home Manager links `/home/yvesd/.config/opencode/opencode.json` to the generated config.

- [ ] **Step 2: Verify OpenCode config**

Run after activation: `opencode debug config`

Expected: resolved config includes `mcp.agentbrowser` and the existing `superpowers` plugin.

- [ ] **Step 3: Verify MCP server registration**

Run after activation: `opencode mcp list`

Expected: `agentbrowser` appears in the MCP server list.

- [ ] **Step 4: Browser automation smoke test**

Ask OpenCode to use `agentbrowser` to navigate to `https://example.com` and read the page title.
