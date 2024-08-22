
# Yves Donato's nixos config
{ inputs, config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./hyprland.nix
      ./unstable.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      #libva
      #libva-utils
      #nvidia-vaapi-driver
      #vaapiVdpau
      #libvdpau-va-gl
    ];
  };

  #environment.variables.VDPAU_DRIVER = "va_gl";
  #environment.variables.LIBVA_DRIVER_NAME = "nvidia";
  
  # Drivers
  services.xserver.videoDrivers = [ "amdgpu" ];
    
  # Networking
  networking.hostName = "nixos";
  
  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  # Password
  services.passSecretService.enable = true;
  
  # Keyring
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
    jack.enable = true;
  };
  
  # Shell Enable
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yvesd = {
    isNormalUser = true;
    description = "Yves Donato";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  environment.variables = {
    EDITOR = "helix";
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };

  services.xserver.excludePackages = [ pkgs.xterm ];

  # Home Mangager
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      yvesd = import ./home.nix;
    };
  };
  
  # Enable automatic login for the user
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "yvesd";

  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Programs
    firefox
    chromium
    rofi-wayland
    gnome.nautilus
    pavucontrol
    pamixer
    discord
    spotify
    blanket
    libreoffice
    obs-studio
    vlc
    audacity
            
    # Zsh
    starship

    # Terminal
    helix
    neovim
    zellij
    git
    neofetch
    wget
    spotify-cli-linux
    killall
    btop
    tlp
    lazygit
    git-credential-manager
    wlr-randr
    lsof
    
    # Languages
    python3
    clang
    clang-tools
    stdenv
    nodejs
    vscode-langservers-extracted
    nodePackages_latest.typescript-language-server
    nodePackages_latest.bash-language-server
    tailwindcss-language-server
    nil

    # system
    xwayland
    swaynotificationcenter
    brightnessctl
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
  ];
  
  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "CascadiaCode" ]; })
  ];
  
  # Garbage colector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "24.05";
}
