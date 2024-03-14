{ inputs, pkgs, ... }: {

    # Hyprland
    environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
  
  programs.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    xwayland.enable = true;
  };
  
  # XDG
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Hyprland Speific Packages
  environment.systemPackages = with pkgs; [
    waybar
    kitty
    swww
    wlogout
    wl-clipboard
    grim
    slurp
    dunst
    hyprpaper
    waypaper
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
