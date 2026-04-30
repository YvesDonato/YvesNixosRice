# Command Palette And OpenCode Permission Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a native Quickshell command palette dashboard and make OpenCode permission prompts produce notifications.

**Architecture:** Implement two independent tracks. The OpenCode track updates the Home Manager-managed OpenCode config/plugin in `homeManager/home.nix`. The Quickshell track adds a new `commandpalette` module under `/home/yvesd/.config/quickshell`, imports it from `shell.qml`, and changes the Hyprland `SUPER+A` binding to toggle it.

**Tech Stack:** NixOS, Home Manager, OpenCode local plugins, Quickshell QML, Hyprland IPC, `qs ipc`, existing rofi backend scripts.

---

### Task 1: OpenCode Permission Notifications

**Files:**
- Modify: `homeManager/home.nix`

- [ ] **Step 1: Make permissions ask for approval**

In the generated `opencode.json`, add a `permission` object that asks for `bash`, `edit`, `task`, and `agentbrowser_*`, while allowing low-risk read/search commands.

- [ ] **Step 2: Listen for both permission event names**

In the generated `notifications.js`, notify on both `permission.updated` and `permission.asked` events, and keep the `permission.ask` hook.

- [ ] **Step 3: Validate**

Run: `nix-instantiate --parse $(rg --files -g '*.nix') >/dev/null`

Run: `alejandra --check $(rg --files -g '*.nix')`

Run: `XDG_CACHE_HOME=/tmp nix build --dry-run --no-link '.#homeConfigurations.yvesd.activationPackage'`

### Task 2: Quickshell Command Palette

**Files:**
- Create: `/home/yvesd/.config/quickshell/modules/commandpalette/qmldir`
- Create: `/home/yvesd/.config/quickshell/modules/commandpalette/CommandPalette.qml`
- Modify: `/home/yvesd/.config/quickshell/shell.qml`
- Modify: `homeManager/modules/hyprland.nix`

- [ ] **Step 1: Add the command palette module**

Create a focused Quickshell module that exposes `IpcHandler { target: "command-palette" }`, displays a centered overlay, filters desktop apps plus static actions, and runs selected actions.

- [ ] **Step 2: Import and instantiate the module**

Import `modules/commandpalette` and add `CommandPalette {}` to `/home/yvesd/.config/quickshell/shell.qml`.

- [ ] **Step 3: Bind SUPER+A**

Change `SUPER+A` from the rofi main menu to `qs ipc call command-palette toggle` in `homeManager/modules/hyprland.nix`.

- [ ] **Step 4: Validate**

Run: `nix-instantiate --parse $(rg --files -g '*.nix') >/dev/null`

Run: `alejandra --check $(rg --files -g '*.nix')`

Run: `qs ipc call command-palette toggle`

Expected: the command palette toggles on the focused screen.
