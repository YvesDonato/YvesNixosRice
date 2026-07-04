{
  inputs,
  lib,
  pkgs,
  pkgs-unstable,
  desktopWindowManager,
  ...
}: let
  mangoPackage = pkgs-unstable.callPackage ../packages/mango-patched.nix {};
in
  lib.mkIf (desktopWindowManager == "mango") {
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    programs.xwayland.enable = true;

    services.displayManager.defaultSession = "mango";
    services.displayManager.sessionPackages = [mangoPackage];

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
