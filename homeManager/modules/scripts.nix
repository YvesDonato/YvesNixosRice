{
  inputs,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  hyprlandPackage = inputs.hyprland.packages.${system}.hyprland;
  quickshellPackage = inputs.quickshell.packages.${system}.default;
  heliumPackage = inputs.helium.packages.${system}.default;

  sessionLock = pkgs.writeShellApplication {
    name = "session-lock";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.swaylock
      quickshellPackage
    ];
    text = ''
      if timeout 2 qs ipc call lock locked true >/dev/null 2>&1; then
        exit 0
      fi

      exec swaylock
    '';
  };

  uniSearch = pkgs.writeShellApplication {
    name = "uni-search";
    runtimeInputs = [
      pkgs.jq
      pkgs.rofi
      pkgs-unstable.aichat
      heliumPackage
    ];
    text = builtins.readFile ./scripts/rofi/uni-search.sh;
  };

  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [
      pkgs.rofi
      pkgs.systemd
      sessionLock
    ];
    text = builtins.readFile ./scripts/rofi/power-menu.sh;
  };

  wifiMenu = pkgs.writeShellApplication {
    name = "wifi-menu";
    runtimeInputs = [
      pkgs.gawk
      pkgs.gnugrep
      pkgs.rofi
      pkgs.util-linux
    ];
    text = builtins.readFile ./scripts/rofi/wifi-menu.sh;
  };

  codebox = pkgs.writeShellApplication {
    name = "codebox";
    runtimeInputs = [
      pkgs.gawk
      pkgs.rofi
      pkgs-unstable.ghostty
      pkgs-unstable.zellij
    ];
    text = builtins.readFile ./scripts/rofi/codebox.sh;
  };

  toggleHeadless = pkgs.writeShellApplication {
    name = "toggle-headless";
    runtimeInputs = [
      pkgs.gnugrep
      hyprlandPackage
    ];
    text = builtins.readFile ./scripts/rofi/toggle-headless.sh;
  };

  toggleLaptopMonitorSide = pkgs.writeShellApplication {
    name = "toggle-laptop-monitor-side";
    runtimeInputs = [
      pkgs.gawk
      pkgs.wlr-randr
      hyprlandPackage
    ];
    text = builtins.readFile ./scripts/toggle-laptop-monitor-side.sh;
  };

  goveeToggle = pkgs.writeShellApplication {
    name = "govee-toggle";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
      pkgs.util-linux
    ];
    text = builtins.readFile ./scripts/lights.bash;
  };

  mainMenu = pkgs.writeShellApplication {
    name = "main-menu";
    runtimeInputs = [
      pkgs.gnugrep
      pkgs.rofi
      hyprlandPackage
      codebox
      powerMenu
      toggleHeadless
      uniSearch
      wifiMenu
    ];
    text = builtins.readFile ./scripts/rofi/main-menu.sh;
  };

  # ghostty 1.3.1 speaks only the Kitty graphics protocol, and zellij 0.44.3
  # proxies no image protocol at all, so inside a pane yazi has no shared
  # protocol and degrades to the chafa text-art adapter (`yazi --debug` reports
  # `Adapter.matches : Chafa`). Not fixable in yazi config. Detach to a bare
  # ghostty window so image/PDF/video/SVG previews render for real -- the same
  # thing Super+E already does. Set YAZI_IN_PANE=1 to opt out.
  yazi = pkgs.writeShellApplication {
    name = "yazi";
    runtimeInputs = [pkgs-unstable.ghostty];
    text = ''
      if [ -n "''${ZELLIJ:-}" ] && [ -z "''${YAZI_IN_PANE:-}" ]; then
        # ghostty inherits our cwd only when it forks a fresh instance, so be explicit.
        if [ "$#" -eq 0 ]; then
          set -- "$PWD"
        fi
        ghostty -e ${lib.getExe pkgs.yazi} "$@" &
        disown
        exit 0
      fi

      exec ${lib.getExe pkgs.yazi} "$@"
    '';
  };
in {
  home.packages = [
    codebox
    goveeToggle
    mainMenu
    powerMenu
    sessionLock
    toggleHeadless
    toggleLaptopMonitorSide
    uniSearch
    wifiMenu
    yazi
  ];
}
