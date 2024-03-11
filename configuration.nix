# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./hyprland.nix
      ./unstable.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.passSecretService.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yvesd = {
    isNormalUser = true;
    description = "Yves Donato";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "yvesd";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Vbox
  #virtualisation.virtualbox.host.enable = true;
  #nixpkgs.config.virtualbox.enableExtensionPack = true;
  #users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

  environment.systemPackages = with pkgs; [
    firefox
    helix
    git
    rofi-wayland
    gnome.nautilus
    python3
    clang
    stdenv
    neofetch
    pavucontrol
    pamixer
    discord
    spotify
    blanket
    libreoffice
    wget
    nodejs
    xwayland
    tk
    gitg
    waypaper
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "CascadiaCode" ]; })
  ];
  
  # Garbage colector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  # Auto Upgrade
  system.autoUpgrade = {
   enable = true;
   channel = "https://nixos.org/channels/nixos-23.11";
  };

  system.stateVersion = "23.11";
}
