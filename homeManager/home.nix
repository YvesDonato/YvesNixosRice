{
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
  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "qs ipc call lock locked true";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "qs ipc call lock locked true";
          }
          {
            timeout = 1200;
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
        $env.config.hooks.env_change.PWD = [
          { |before, after|
              let remote_dir = ($nu.home-path | path join "remote") # CHANGE THIS to your folder

              # ---------------------------
              # 1. ACTION: ENTERING (Mount)
              # ---------------------------
              if ($after == $remote_dir) {
                  # Check if it's already mounted by seeing if it's empty
                  # (Using a try/catch prevents crashing if the folder is weird)
                  try {
                      if (ls $after | is-empty) { 
                          print "🔌 Mounting Codebox..."
                          # Using -o reconnect is crucial for auto-recovery
                          sshfs -o reconnect yves@codebox:/home/yves/code $after
                      }
                  }
              }
          }
      ]
      '';
      shellAliases = {
        update = "sudo nixos-rebuild switch";
        clean = "sudo nix-collect-garbage -d";
        z = "zeditor";
        c = "cd";
        h = "hx";
      };

    };

    ghostty = {
      enable = true;
      settings = {
        theme = "TokyoNight Moon";
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
      };
    };
    
    starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
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
