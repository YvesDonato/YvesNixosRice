# Yves Donato's nixos config
{
  inputs,
  pkgs,
  config,
  pkgs-unstable,
  desktopWindowManager,
  lib,
  ...
}: {
  assertions = [
    {
      assertion = builtins.elem desktopWindowManager ["hyprland" "mango"];
      message = "desktopWindowManager must be either \"hyprland\" or \"mango\".";
    }
  ];

  imports = [
    ./hardware-configuration.nix
    ./modules/hyprland.nix
    ./modules/mango.nix

    ./modules/packages/unstable.nix
    ./modules/packages/stable.nix

    inputs.home-manager.nixosModules.home-manager
  ];

  # Bootloader
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 1;
    tmp.cleanOnBoot = true;
    initrd.kernelModules = ["amdgpu" "uinput"];
    initrd.systemd.network.wait-online.enable = false;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "v4l2loopback"
    ];
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;

      powerManagement = {
        enable = true;
        finegrained = true;
      };

      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        nvidiaBusId = "PCI:1:0:0";
        amdgpuBusId = "PCI:101:0:0";
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };

    # Bluetooth
    bluetooth.enable = true; # enables support for Bluetooth
    bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
    xpadneo.enable = true;
    opentabletdriver.enable = true;
    uinput.enable = true;
  };

  services = {
    blueman.enable = true;
    printing.enable = true;
    passSecretService.enable = true;
    gnome.gnome-keyring.enable = true;
    displayManager.gdm.enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "yvesd";
    tailscale.enable = true;
    pulseaudio.enable = false;
    udisks2.enable = true;

    journald.extraConfig = ''
      SystemMaxUse=512M
      RuntimeMaxUse=128M
      MaxRetentionSec=14day
      RateLimitIntervalSec=30s
      RateLimitBurst=1000
    '';

    logind = {
      settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchDocked = "ignore";
        HandleLidSwitchExternalPower = "ignore";
      };
    };

    openssh = {
      enable = true;
      startWhenNeeded = true;
      ports = [22];
      settings = {
        PasswordAuthentication = true;
        AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
        UseDns = false;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
      };
    };

    # sunshine = {
    #   enable = true;
    #   autoStart = true;
    #   capSysAdmin = true;
    #   openFirewall = true;
    # };

    xserver = {
      enable = true;
      videoDrivers = ["amdgpu" "nvidia"];
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

  programs.nm-applet = {
    enable = true;
    indicator = true;
  };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openconnect
      ];
      ensureProfiles.profiles.sheridan-vpn = {
        connection = {
          id = "Sheridan VPN";
          uuid = "c5a1e30d-1f3d-4f73-88f6-ec1e7b515059";
          type = "vpn";
          autoconnect = false;
        };
        vpn = {
          "service-type" = "org.freedesktop.NetworkManager.openconnect";
          gateway = "vpn.sheridancollege.ca";
          remote = "vpn.sheridancollege.ca";
          protocol = "anyconnect";
          useragent = "AnyConnect";
          authtype = "password";
        };
      };
    };
  };

  # Compressed in-memory swap helps avoid stalls or OOM kills under memory spikes.
  zramSwap = {
    enable = true;
    memoryPercent = 25;
    algorithm = "zstd";
  };

  # Avoid extra metadata writes on the SSD root filesystem.
  fileSystems."/".options = ["noatime"];

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
      sddm.enableGnomeKeyring = true;
      hyprlock = {};
    };
    polkit.enable = true;
    rtkit.enable = true;
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = ["root" "yvesd"];
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
      "kvm"
      "adbusers"
      "docker"
    ];
    shell = pkgs.nushell;
  };

  environment.variables = {
    EDITOR = "nvim";
    BROWSER = "zen-beta";
    TERMINAL = "ghostty";
  };

  # Home Manager
  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs;
      inherit pkgs-unstable;
      inherit desktopWindowManager;
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
  users.extraGroups.vboxusers.members = ["yvesd"];

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [
        "--all"
        "--filter=until=168h"
      ];
    };
  };

  programs.adb.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.direnv.enable = true;
  programs.nix-ld.enable = true;

  # Fonts
  fonts = {
    fontconfig = {
      subpixel.rgba = "none";
      hinting.enable = true;
      hinting.style = "slight";
    };

    packages = with pkgs; [
      nerd-fonts.hack
    ];
  };

  # Garbage collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.11";
}
