{ config, pkgs, pkgs-unstable, ...}:{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs-unstable; [
    hyprlock
    electron
    obsidian
  ];
}
