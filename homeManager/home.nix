{
  lib,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {
  imports = [
    ./modules/hyprland.nix
    ./modules/nixvim.nix
    # ./modules/helix.nix
    # ./modules/zed-editor.nix
  ];

  home = {
    username = "yvesd";
    homeDirectory = "/home/yvesd";
    stateVersion = "25.11";

    packages = [
    ];

    file = {
      ".config/opencode/opencode.json" = {
        force = true;
        text =
          builtins.toJSON {
            "$schema" = "https://opencode.ai/config.json";
            plugin = ["superpowers@git+https://github.com/obra/superpowers.git"];
            mcp = {
              agentbrowser = {
                type = "local";
                command = [
                  (lib.getExe' pkgs.nodejs "npx")
                  "-y"
                  "@playwright/mcp@0.0.71"
                  "--executable-path"
                  (lib.getExe pkgs.chromium)
                  "--no-sandbox"
                  "--output-dir"
                  "/tmp/opencode-agentbrowser"
                ];
                environment = {
                  PATH = "${lib.makeBinPath [pkgs.nodejs]}:{env:PATH}";
                };
                enabled = true;
              };
            };
          }
          + "\n";
      };
    };

    sessionVariables = {
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "Adwaita-dark";
    style = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  systemd.user.services = {
    quickshell = {
      Unit = {
        Description = "Quickshell desktop shell";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/quickshell";
        Restart = "on-failure";
        RestartSec = 2;
        MemoryHigh = "512M";
        MemoryMax = "1G";
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    quickshell-notification-server = {
      Unit = {
        Description = "Quickshell notification HTTP bridge";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${pkgs.python3}/bin/python3 -u /home/yvesd/.config/quickshell/scripts/notification-server.py";
        Restart = "on-failure";
        RestartSec = 2;
        MemoryHigh = "64M";
        MemoryMax = "128M";
        TasksMax = 32;
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };

  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "qs ipc call lock locked true";
          after_sleep_cmd = "sleep 0.5; hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
          lock_cmd = "qs ipc call lock locked true";
        };

        listener = [
          {
            timeout = 1800;
            on-timeout = "qs ipc call lock locked true";
          }
          {
            timeout = 1810;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

  programs = {
    zoxide = {
      enable = true;
      enableNushellIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    nushell = {
      enable = true;
      extraConfig = ''
        $env.config = {
          show_banner: false,
        }
      '';
      shellAliases = {
        update = "sudo nixos-rebuild switch";
        clean = "sudo nix-collect-garbage -d";
        z = "zeditor";
        c = "cd";
        h = "nvim";
      };
    };

    ghostty = {
      enable = true;
      settings = {
        theme = "TokyoNight Moon";
        background-opacity = 0.80;
        background-blur = false;
        copy-on-select = false;
        keybind = [
          "ctrl+v=paste_from_clipboard"
          "ctrl+y=copy_to_clipboard"
          "ctrl+1=decrease_font_size:1"
          "ctrl+2=increase_font_size:1"
          "ctrl+r=reset_font_size"
        ];
      };
    };

    zellij = {
      enable = true;
      package = pkgs-unstable.zellij;
      settings = {
        theme = "tokyo-night-dark";
        default_layout = "compact";
        simplified_ui = true;
        pane_frames = false;
        show_startup_tips = false;
        copy_on_select = false;
      };
    };

    starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        aws.disabled = true;
      };
    };

    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };
  };
  programs.home-manager.enable = true;
}
