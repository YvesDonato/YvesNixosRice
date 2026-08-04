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
    # Kernel + nvidia must move in lockstep; stable's nvidia (580.142) can't
    # build against stable's linuxPackages_latest (7.1.2, of_gpio.h removal),
    # while unstable pairs 7.1.2 with nvidia 595.x and Hydra caches that combo.
    kernelPackages = pkgs-unstable.linuxPackages_latest;
    kernelModules = [
      "v4l2loopback"
    ];
    # Out-of-tree module; without this v4l2loopback never gets built and
    # systemd-modules-load fails on every boot.
    extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
    kernel.sysctl = {
      # High swappiness is the recommended pairing for zstd zram swap.
      "vm.swappiness" = 180;
      # Default 3 = 8-page readahead per swap-in, which multiplies cost on both
      # swap tiers at this swappiness. 0 is the standard zram pairing.
      "vm.page-cluster" = 0;
      # Restores Alt+SysRq+f (manual OOM kill) and REISUB as a hang escape hatch;
      # the default 16 leaves neither available.
      "kernel.sysrq" = 1;
    };
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
    uinput.enable = true;
  };

  services = {
    blueman.enable = true;
    printing.enable = true;
    passSecretService.enable = false;
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
        HandleLidSwitch = "suspend";
        # On AC or docked the lid stays a no-op on purpose: long jobs keep
        # running with the laptop closed.
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
    };

    # asusd owns the ACPI platform profile and leaves it at `performance`, which
    # pins amd-pstate EPP to performance on all 16 cores even on battery. tlp was
    # already installed as a package with no service; enable it so AC and battery
    # actually differ. Profile choices on this box: quiet balanced performance.
    tlp = {
      enable = true;
      settings = {
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";
        # nvidia's own udev rules already set power/control=auto on 01:00.0;
        # keep tlp out of it so the two don't fight over RTD3.
        RUNTIME_PM_DENYLIST = "01:00.0";
        # USB autosuspend breaks HID/dongles more often than it saves power.
        USB_AUTOSUSPEND = 0;
      };
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
    memoryPercent = 60;
    algorithm = "zstd";
  };

  # Disk overflow tier below zram: when zram fills (e.g. long browser uptime),
  # cold pages spill to NVMe instead of thrash-scanning a full RAM-backed swap.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # MiB
      priority = 0; # below zram (5)
    }
  ];

  # Avoid extra metadata writes on the SSD root filesystem.
  fileSystems."/".options = ["noatime"];

  systemd = {
    services = {
      NetworkManager-wait-online.enable = pkgs.lib.mkForce false;
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };

    # Kill runaway workloads before they hard-lock the machine; the host has
    # crashed under heavy parallel load with kernel OOM alone.
    oomd = {
      enable = true;
      enableRootSlice = true;
      enableUserSlices = true;
      # oomd's default SwapUsedLimit=90% is 90% of TOTAL swap. Adding the 32 GiB
      # disk tier raised the trigger from 16.5 GiB to 45.3 GiB of 50.3 GiB, so the
      # machine had to fully thrash NVMe before oomd acted (journal, Jul 24).
      # 45% ~= 22.6 GiB, just past zram's 18.3 GiB.
      # (systemd.oomd.extraConfig was renamed to settings.OOM in 26.05.)
      settings.OOM.SwapUsedLimit = "45%";
    };
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  security = {
    pam.services = {
      gdm-password.enableGnomeKeyring = true;
      gdm-autologin.enableGnomeKeyring = true;
      hyprlock = {};
      swaylock.text = ''
        auth include login
      '';
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
      # 4 jobs x 4 cores = 16 threads, matching the thread count. Unset this and
      # nix runs max-jobs=auto (16) x cores=0 (16) = 256 concurrent compilers,
      # which is how this host has hard-locked under parallel load.
      max-jobs = 4;
      cores = 4;
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
      "dialout"
    ];
    shell = pkgs.nushell;
  };

  environment.variables = {
    EDITOR = "nvim";
    BROWSER = "helium";
    TERMINAL = "ghostty";
  };

  # Home Manager
  home-manager = {
    # Reuse the system nixpkgs (incl. allowUnfree) instead of a second
    # instantiation — 26.05 marks some nixvim plugins unfree, and HM's own
    # instance wouldn't inherit nixpkgs.config.allowUnfree from below.
    useGlobalPkgs = true;
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

  # programs.adb was removed in 26.05 (systemd handles uaccess rules now);
  # android-tools in systemPackages provides the adb command instead.

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
    dates = "Sun 03:00";
    options = "--delete-older-than 7d";
  };

  # Scheduled hard-link dedup of the store (cheaper than auto-optimise-store,
  # which would slow every build).
  nix.optimise.automatic = true;
  nix.optimise.dates = ["Sun 04:00"];

  system.stateVersion = "25.11";
}
