{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: let
  hyprlandConfigFragments = [
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
    package = pkgs.hyprland;
    plugins = [
      pkgs.hyprlandPlugins.hy3
    ];
    extraConfig = builtins.concatStringsSep "" hyprlandConfigFragments;
  };
}
