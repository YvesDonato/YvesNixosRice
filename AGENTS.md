# Repository Guidelines

## Project Structure & Module Organization
This repository defines a NixOS system and a Home Manager user environment.

- `flake.nix` and `flake.lock` define inputs, outputs, and package channels.
- `configuration.nix` is the main NixOS module for boot, hardware, services, users, fonts, Nix settings, and Home Manager integration.
- `hardware-configuration.nix` contains generated hardware and filesystem declarations; avoid manual churn unless hardware or mount policy changes.
- `modules/` contains system-level modules, including Hyprland setup and stable/unstable package lists.
- `homeManager/home.nix` is the main user profile.
- `homeManager/modules/` contains user-level modules such as Hyprland, Nixvim, Helix, and Zed.
- `homeManager/modules/scripts/` contains shell scripts used by rofi and Hyprland bindings.

## Build, Test, and Development Commands
Run validation from the repository root.

- `alejandra --check $(rg --files -g '*.nix')`: check Nix formatting.
- `nix-instantiate --parse $(rg --files -g '*.nix') >/dev/null`: parse all Nix files quickly.
- `shfmt -d $(rg --files -g '*.sh' -g '*.bash')`: check shell formatting.
- `bash -n path/to/script.sh`: syntax-check shell scripts.
- `XDG_CACHE_HOME=/tmp nix build --dry-run --no-link '.#nixosConfigurations."nixos".config.system.build.toplevel'`: validate the NixOS system build.
- `XDG_CACHE_HOME=/tmp nix build --dry-run --no-link '.#homeConfigurations.yvesd.activationPackage'`: validate standalone Home Manager activation.

## Coding Style & Naming Conventions
Use Alejandra formatting for all `.nix` files. Prefer two-space indentation in shell scripts after `shfmt`. Keep module names lowercase and descriptive, for example `homeManager/modules/nixvim.nix`. Avoid hardcoding duplicate package names across stable and unstable lists unless the channel choice is intentional.

## Testing Guidelines
There is no separate test suite. Treat parse checks, formatter checks, shell syntax checks, and Nix dry-run builds as the required validation gate. When changing Hyprland, Home Manager services, or boot settings, validate both the NixOS and Home Manager outputs.

## Commit & Pull Request Guidelines
Recent history uses short imperative or scoped messages such as `Refactor: big codex refactor`, `Nix: nix flake updated`, and `Update: Flake/packages`. Keep commits concise and mention the affected area when possible. Pull requests should describe the configuration impact, list validation commands run, and call out user-visible behavior changes such as service startup, boot, display, lockscreen, or package-channel changes.

## Security & Configuration Tips
Do not commit secrets, API keys, private hostnames, or machine-specific tokens. Be careful with `permittedInsecurePackages`, unfree packages, SSH settings, remote-access services, and autostarted daemons. Preserve unrelated local changes in this dirty-worktree style repository; do not reset or revert files unless explicitly asked.
