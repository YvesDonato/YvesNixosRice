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
    #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
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
    waybar
    kitty
    wlogout
    wl-clipboard
    grim
    slurp
    swww
    waypaper
    hyprcursor
    hypridle
    hyprlock
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
