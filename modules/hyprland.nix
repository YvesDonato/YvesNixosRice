{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}: {
  # Hyprland
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  # XDG
  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  # Hyprland Speific Packages
  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
    waypaper
    hyprcursor
    hypridle
    hyprlock
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Security
  security = {
    pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
  };
}
