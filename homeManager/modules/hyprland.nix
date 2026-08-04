{
  lib,
  pkgs,
  pkgs-unstable,
  inputs,
  desktopWindowManager,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  hyprlandPackage = inputs.hyprland.packages.${system}.hyprland;
  systemdRun = lib.getExe' pkgs.systemd "systemd-run";
  vesktop = lib.getExe pkgs-unstable.vesktop;
  spotify = lib.getExe pkgs-unstable.spotify;
  ghostty = lib.getExe pkgs-unstable.ghostty;
  herdr = lib.getExe inputs.herdr.packages.${system}.default;
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
  hyprlandLifecycleConfig = ''
    -- Start desktop apps once per Hyprland session without changing workspace.
    hl.on("hyprland.start", function()
      hl.exec_cmd("${systemdRun} --user --scope --quiet --collect -- ${vesktop}")
      hl.exec_cmd("${systemdRun} --user --scope --quiet --collect -- ${spotify}")
      hl.exec_cmd("${systemdRun} --user --scope --quiet --collect -- ${ghostty} --class=com.yvesd.herdr -e ${herdr}")
    end)

    -- Stop graphical-session services whenever Hyprland exits normally.
    hl.on("hyprland.shutdown", function()
      hl.exec_cmd("${lib.getExe' pkgs.systemd "systemctl"} --user stop graphical-session.target")
    end)
  '';
in
  lib.mkIf (desktopWindowManager == "hyprland") {
    wayland.windowManager.hyprland = {
      enable = true;
      package = hyprlandPackage;
      systemd.enable = true;
      # Explicit since the 26.05 HM default changed hyprlang -> lua; this
      # repo's fragments are concatenated into Home Manager's generated Lua.
      configType = "lua";
      extraConfig = builtins.concatStringsSep "\n" (hyprlandLuaFragments ++ [hyprlandLifecycleConfig]);
    };
  }
