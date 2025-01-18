# Yves Donato's nixos config
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./hyprland.nix
    ./unstable.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  # Bootloader
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    blacklistedKernelModules = [
      "nouveau"
      "nvidia_drm"
      "nvidia"
    ];
    initrd.kernelModules = ["amdgpu"];
    initrd.systemd.network.wait-online.enable = false;
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    pulseaudio.enable = false;

    # Bluetooth
    bluetooth.enable = true; # enables support for Bluetooth
    bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };

  services = {
    blueman.enable = true;
    printing.enable = true;
    passSecretService.enable = true;
    gnome.gnome-keyring.enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "yvesd";
    tailscale.enable = true;

    xserver = {
      enable = true;
      videoDrivers = ["amdgpu"];
      displayManager.gdm.enable = true;
      excludePackages = [pkgs.xterm];
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  systemd = {
    services = {
      NetworkManager-wait-online.enable = pkgs.lib.mkForce false;
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  security = {
    pam.services = {
      ightdm.enableGnomeKeyring = true;
      sddm.enableGnomeKeyring = true;
      hyprlock = {};
    };

    rtkit.enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Shell Enable
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yvesd = {
    isNormalUser = true;
    description = "Yves Donato";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.nushell;
  };

  environment.variables = {
    EDITOR = "helix";
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };

  # Home Manager
  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit inputs;};
    users = {
      yvesd = import ./home.nix;
    };
  };

  # Virtualbox
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
  users.extraGroups.vboxusers.members = ["user-with-access-to-virtualbox"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.direnv.enable = true;
  environment.systemPackages = with pkgs; [
    # Programs
    inputs.zen-browser.packages."${system}".default
    chromium
    anki
    rofi-wayland
    nautilus
    pavucontrol
    pamixer
    discord
    spotify
    blanket
    libreoffice
    obs-studio
    vlc
    tailscale
    blueman
    pomodoro-gtk

    # Zsh
    starship

    # Terminal
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
    yazi
    asusctl
    supergfxctl
    lshw
    glow

    # Languages
    prettierd
    alejandra

    # system
    xwayland
    swaynotificationcenter
    brightnessctl
    hyprlock
    gnome-disk-utility
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
  ];

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "DroidSansMono"
        "CascadiaCode"
      ];
    })
  ];

  # Garbage collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "24.11";
}
