# Yves Donato's nixos config
{
  inputs,
  pkgs,
  config,
  pkgs-unstable,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./modules/hyprland.nix

    ./modules/packages/unstable.nix
    ./modules/packages/stable.nix

    inputs.home-manager.nixosModules.home-manager
  ];

  # Bootloader
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.kernelModules = ["amdgpu"];
    initrd.systemd.network.wait-online.enable = false;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # nvidia = {
    #   modesetting.enable = true;
    #
    #   powerManagement = {
    #     enable = true;
    #     finegrained = true;
    #   };
    #
    #   open = true;
    #   nvidiaSettings = true;
    #
    #   package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #     version = "570.86.16";
    #     sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
    #     openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
    #     settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
    #     usePersistenced = false;
    #   };
    #
    #   prime = {
    #     nvidiaBusId = "PCI:1:0:0";
    #     amdgpuBusId = "PCI:101:0:0";
    #     offload = {
    #       enable = true;
    #       enableOffloadCmd = true;
    #     };
    #   };
    # };
    #

    # Bluetooth
    bluetooth.enable = true; # enables support for Bluetooth
    bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
    xpadneo.enable = true;
  };

  services = {
    blueman.enable = true;
    printing.enable = true;
    passSecretService.enable = true;
    gnome.gnome-keyring.enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "yvesd";
    tailscale.enable = true;
    pulseaudio.enable = false;

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

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "root" "yvesd" ];
    };
    extraOptions = ''
         extra-substituters = https://devenv.cachix.org
         extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
       '';
  };
  # cachix.enable = false;

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
    extraSpecialArgs = {
      inherit inputs;
      inherit pkgs-unstable;
    };
    users = {
      yvesd = import ./homeManager/home.nix;
    };
  };

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["yvesd"];
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  users.extraGroups.vboxusers.members = ["user-with-access-to-virtualbox"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.direnv.enable = true;

  programs.nix-ld.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];
  
  # Garbage collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.05";
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };
}
