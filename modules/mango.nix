{
  inputs,
  lib,
  pkgs,
  pkgs-unstable,
  desktopWindowManager,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  mangoPackage = pkgs-unstable.callPackage ../packages/mango-patched.nix {
    mango = inputs.mango.packages.${system}.default;
  };
  mangoSessionWrapper = pkgs.writeShellApplication {
    name = "mango-session";
    # Both helpers are invoked indirectly by trap actions.
    excludeShellChecks = ["SC2329"];
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
    ];
    text = ''
      compositor_pid=""

      stop_graphical_session() {
        systemctl --user stop graphical-session.target >/dev/null 2>&1 || true
      }

      forward_signal() {
        local signal="$1"
        if [[ -n "$compositor_pid" ]] && kill -0 "$compositor_pid" 2>/dev/null; then
          kill -s "$signal" "$compositor_pid" 2>/dev/null || true
        fi
      }

      trap stop_graphical_session EXIT
      trap 'forward_signal HUP' HUP
      trap 'forward_signal INT' INT
      trap 'forward_signal TERM' TERM

      ${lib.getExe mangoPackage} &
      compositor_pid=$!

      set +e
      wait "$compositor_pid"
      status=$?
      while kill -0 "$compositor_pid" 2>/dev/null; do
        wait "$compositor_pid"
        status=$?
      done
      set -e

      exit "$status"
    '';
  };
  mangoSession = pkgs.writeTextFile {
    name = "mango-wayland-session";
    destination = "/share/wayland-sessions/mango.desktop";
    passthru.providedSessions = ["mango"];
    text = ''
      [Desktop Entry]
      Encoding=UTF-8
      Name=Mango
      DesktopNames=mango;wlroots
      Comment=mango WM
      Exec=${lib.getExe mangoSessionWrapper}
      Icon=mango
      Type=Application
    '';
  };
in
  lib.mkIf (desktopWindowManager == "mango") {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.xwayland.enable = true;

    services.displayManager.defaultSession = "mango";
    services.displayManager.sessionPackages = [mangoSession];

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      config.common.default = "*";
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    environment.systemPackages =
      [mangoPackage]
      ++ (with pkgs; [
        wl-clipboard
        grim
        slurp
        waypaper
        wlr-randr
        inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
      ]);

    security.polkit.enable = lib.mkDefault true;
  }
