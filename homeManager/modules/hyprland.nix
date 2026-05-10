{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  hyprlandPackage = inputs.hyprland.packages.${system}.hyprland;
  hyprlandLuaFragments = [
    (import ./hyprland/monitors.nix)
    (import ./hyprland/environment.nix)
    (import ./hyprland/input.nix)
    (import ./hyprland/appearance.nix)
    (import ./hyprland/workspace-rules.nix)
    (import ./hyprland/misc.nix)
    (import ./hyprland/bindings.nix)
    (import ./hyprland/window-rules.nix)
    (import ./hyprland/navigation.nix)
  ];
in {
  imports = [
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprlandPackage;
    systemd.enable = false;
  };

  xdg.configFile."hypr/hyprland.lua" = {
    text = builtins.concatStringsSep "\n" hyprlandLuaFragments;
    onChange = ''
      if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 || true
      fi
    '';
  };
}
