{
  inputs,
  lib,
  pkgs,
  desktopWindowManager,
  ...
}: let
  mangoPackage = pkgs.mangowc.overrideAttrs (oldAttrs: {
    patches =
      (oldAttrs.patches or [])
      ++ [
        ../patches/mangowc-repaint-focus-borders.patch
      ];
  });
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
