# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single-host NixOS flake (host `nixos`, x86_64-linux, user `yvesd`) for an ASUS AMD+Nvidia laptop, plus a Home Manager user environment. The README is outdated — the actual stack is: WM mango (or Hyprland, see toggle below), terminal ghostty, shell nushell, editor nixvim, browser zen, desktop shell Quickshell.

## Validation commands

There is no test suite. The validation gate, run from the repo root:

```bash
alejandra --check $(rg --files -g '*.nix')          # Nix formatting (alejandra is the formatter)
nix-instantiate --parse $(rg --files -g '*.nix') >/dev/null   # fast parse check of all .nix files
bash -n path/to/script.sh                            # syntax-check shell scripts (shfmt is NOT installed)
# Full evaluation check of both outputs:
XDG_CACHE_HOME=/tmp nix build --dry-run --no-link '.#nixosConfigurations."nixos".config.system.build.toplevel'
XDG_CACHE_HOME=/tmp nix build --dry-run --no-link '.#homeConfigurations.yvesd.activationPackage'
```

When changing WM config, Home Manager services, or boot settings, dry-run-build **both** the NixOS and Home Manager outputs (home.nix is evaluated in both). For WM-conditional changes, the pinned variants (`.#nixosConfigurations."nixos-hyprland"`, `.#homeConfigurations.yvesd-hyprland`, and the `-mango` counterparts) validate the non-active WM path.

Applying changes (the user runs these; `update` is a nushell alias for the first):

```bash
sudo nixos-rebuild switch                # targets nixosConfigurations.nixos (flake in /etc/nixos or via symlink)
home-manager switch --flake '.#yvesd'    # standalone HM activation
```

## Architecture

### The window-manager toggle

`desktopWindowManager` ("mango" | "hyprland") is a let-binding near the top of `flake.nix`. It flows as a `specialArgs`/`extraSpecialArgs` string into every module. Both WM modules are **always imported**; each one's entire body is wrapped in `lib.mkIf (desktopWindowManager == "...")`, so selection happens inside the modules. The flake exposes pinned variants alongside the defaults: `nixosConfigurations.{nixos,nixos-mango,nixos-hyprland}` and `homeConfigurations.{yvesd,yvesd-mango,yvesd-hyprland}`.

Consequence: WM-related changes (bindings, monitors, window rules) usually need to be mirrored in **both** WM configs — they deliberately keep the same Super-key bindings, monitor layout, and TokyoNight border colors:

- **Hyprland**: config is *Lua*, not hyprland.conf. `homeManager/modules/hyprland.nix` concatenates nine string fragments from `homeManager/modules/hyprland/` (monitors, bindings, navigation, window-rules, …) into `~/.config/hypr/hyprland.lua`. Fragment order matters: `bindings.nix` defines Lua locals (e.g. `mainMod`) that `navigation.nix` reuses.
- **Mango**: one inline string in `homeManager/modules/mango.nix` written to `~/.config/mango/config.conf`, plus generated lid-switch/autostart scripts and a `mango-lid-switch` systemd user service. System-side, `modules/mango.nix` builds `pkgs.mangowc` with `overrideAttrs`, applying the two local patches in `patches/`.

System WM modules also differ in sourcing: Hyprland comes from the `hyprland` flake input (with hyprland.cachix.org substituter), not nixpkgs.

### Dual nixpkgs channels

`flake.nix` evaluates stable (`nixos-25.11`, used for the system and HM) and `nixpkgs-unstable` as **two independent imports** — no overlay. `pkgs-unstable` is passed around as a specialArg. Package lists are split by channel: `modules/packages/stable.nix` (`with pkgs`) vs `modules/packages/unstable.nix` (`with pkgs-unstable`). Don't list the same package in both unless the channel choice is intentional.

### Home Manager runs two ways

`homeManager/home.nix` is used both as a NixOS module (wired in `configuration.nix`) and standalone (flake `homeConfigurations`). Changes must evaluate in both contexts. Only `inputs`, `pkgs-unstable`, and `desktopWindowManager` are passed in **both**; `name` and `piCodingAgent` exist only in the NixOS `specialArgs`, so Home Manager modules cannot reference them. (Standalone also passes `username`, but home.nix hardcodes it and ignores the arg.)

### Custom package: pi-coding-agent

`packages/pi-coding-agent.nix` is a `buildNpmPackage` of the npm tarball `@earendil-works/pi-coding-agent` (binary `pi`), built from `pkgs-unstable` via `callPackage` in `flake.nix` and exposed as `packages.x86_64-linux.pi-coding-agent`. Its `postPatch` uses exact-match `substituteInPlace --replace-fail` strings to inject integrity hashes into npm-shrinkwrap.json — these break on version bumps and must be updated together with the version/hash.

### Scripts are not Nix-managed

`homeManager/modules/scripts/` (rofi menus, scratchpad toggles, etc.) is referenced by **absolute repo path** from WM bindings and from `~/.config/quickshell` (which is itself unmanaged except for `quickshell/generated/desktop-wm`). Moving or renaming a script silently breaks keybindings. Scripts probe `hyprctl` vs `mmsg`/`wlr-randr` at runtime to work under both WMs.

### Theming

Manual TokyoNight everywhere (ghostty "TokyoNight Moon", zellij, nixvim "storm", WM border colors as hardcoded hexes). No stylix; the `nix-colors` flake input is currently unused. `helix.nix` and `zed-editor.nix` exist under `homeManager/modules/` but are commented out of `home.nix`.

### Agent/tooling dirs (not part of the Nix build)

`.pi/` configures the Pi coding agent tool itself; `docs/superpowers/` is historical planning artifacts. Neither affects evaluation.

## Conventions

- Format all `.nix` files with alejandra; module names lowercase and descriptive.
- Commit messages: short type-prefixed imperative, e.g. `feat: Pi agent harness`, `Refactor: big codex refactor`.
- This is a dirty-worktree-style repo: unrelated local modifications are normal. Preserve them; never reset or revert files unless explicitly asked.
- `hardware-configuration.nix` is generated — avoid manual churn.
- Don't commit secrets or machine-specific tokens; be careful around the openssh, VPN (`sheridan-vpn`), and autologin settings in `configuration.nix`.
