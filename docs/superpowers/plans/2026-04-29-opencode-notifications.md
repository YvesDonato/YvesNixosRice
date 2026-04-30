# OpenCode Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add OpenCode desktop notifications for completed responses, errors, and permission prompts.

**Architecture:** Manage a global local OpenCode plugin from Home Manager by writing `~/.config/opencode/plugins/notifications.js`. The plugin listens to OpenCode lifecycle hooks and calls `notify-send`, with a best-effort fallback to the existing Quickshell HTTP notification bridge.

**Tech Stack:** NixOS, Home Manager, OpenCode local plugins, `notify-send`, Quickshell notification bridge on `127.0.0.1:9999`.

---

### Task 1: Add Notification Plugin

**Files:**
- Modify: `homeManager/home.nix`

- [ ] **Step 1: Verify plugin target is absent**

Run: `nix eval '.#homeConfigurations.yvesd.config.home.file.".config/opencode/plugins/notifications.js".text'`

Expected: evaluation fails because the plugin file is not defined yet.

- [ ] **Step 2: Add the plugin file declaration**

Add a `".config/opencode/plugins/notifications.js"` entry under `home.file` in `homeManager/home.nix`. The plugin must export `OpenCodeNotifications`, send `notify-send -a OpenCode`, and handle `session.idle`, `session.error`, and `permission.ask`.

- [ ] **Step 3: Verify plugin target exists**

Run: `nix eval --raw '.#homeConfigurations.yvesd.config.home.file.".config/opencode/plugins/notifications.js".text' >/dev/null`

Expected: exits successfully with no output.

### Task 2: Validate And Activate

**Files:**
- Validate: `homeManager/home.nix`

- [ ] **Step 1: Parse all Nix files**

Run: `nix-instantiate --parse $(rg --files -g '*.nix') >/dev/null`

Expected: exits successfully with no output.

- [ ] **Step 2: Check formatting**

Run: `alejandra --check $(rg --files -g '*.nix')`

Expected: exits successfully with no formatting errors.

- [ ] **Step 3: Dry-run Home Manager activation**

Run: `XDG_CACHE_HOME=/tmp nix build --dry-run --no-link '.#homeConfigurations.yvesd.activationPackage'`

Expected: Home Manager evaluates successfully.

- [ ] **Step 4: Activate the profile**

Run: `profile=$(nix build --print-out-paths --no-link '.#homeConfigurations.yvesd.activationPackage') && "$profile/activate"`

Expected: Home Manager links `~/.config/opencode/plugins/notifications.js`.

### Task 3: Smoke Test Notifications

**Files:**
- Runtime target: `/home/yvesd/.config/opencode/plugins/notifications.js`

- [ ] **Step 1: Verify OpenCode sees the plugin file**

Run: `opencode debug config`

Expected: command succeeds with existing config intact.

- [ ] **Step 2: Send a desktop notification directly**

Run: `notify-send -a OpenCode "OpenCode notification test" "Direct notify-send works"`

Expected: command exits successfully.

- [ ] **Step 3: Exercise OpenCode session notification**

Run: `opencode run "Reply with the word done." --model <available-model>`

Expected: OpenCode completes the run and the `session.idle` hook emits an OpenCode notification.
