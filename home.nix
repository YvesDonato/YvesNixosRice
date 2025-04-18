{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {
  home = {
    username = "yvesd";
    homeDirectory = "/home/yvesd";
    stateVersion = "24.11";
    packages = [
    ];

    file = {
    };

    sessionVariables = {
    };
  };

  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
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
        c = "cd";
        h = "hx";
      };
    };

    nixvim = {
      enable = true;
      enableMan = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      luaLoader.enable = true;

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      colorschemes.tokyonight = {
        enable = true;
        settings.style = "night";
      };

      plugins = {
        alpha = {
          enable = true;
          theme = "dashboard";
        };

        vimtex = {
          enable = true;
        };

        lualine = {
          enable = true;
        };

        which-key = {
          enable = true;
        };

        gitsigns = {
          enable = true;
        };

        web-devicons = {
          enable = true;
        };

        indent-blankline = {
          enable = true;
        };

        notify = {
          enable = true;
        };

        # avante = {
        #   enable = true;
        #   settings = {
        #     provider = "copilot";
        #   };
        # };

        telescope = {
          enable = true;
          extensions = {
            fzf-native.enable = true;
            undo.enable = true;
          };

          settings.defaults = {
            prompt_prefix = "   ";
            color_devicons = true;
            set_env.COLORTERM = "truecolor";

            mappings = {
              i = {
                "<esc>".__raw = ''
                  function(...)
                    return require("telescope.actions").close(...)
                  end'';
                "<c-t>".__raw = ''
                  function(...)
                    require('trouble.providers.telescope').open_with_trouble(...);
                  end
                '';
              };
              n = {
                "<c-t>".__raw = ''
                  function(...)
                    require('trouble.providers.telescope').open_with_trouble(...);
                  end
                '';
              };
            };
            # trim leading whitespace from grep
            vimgrep_arguments = [
              "${pkgs.ripgrep}/bin/rg"
              "--color=never"
              "--no-heading"
              "--with-filename"
              "--line-number"
              "--column"
              "--smart-case"
              "--trim"
            ];
          };

          keymaps = {
            "<leader>fp" = {
              action = "projects";
              options.desc = "Search Todo";
            };
            "<leader>st" = {
              action = "todo-comments";
              options.desc = "Search Todo";
            };
            "<leader>sn" = {
              action = "notify";
              options.desc = "Search Notifications";
            };
            "<leader>su" = {
              action = "undo";
              options.desc = "Search Undo";
            };
            "<leader><space>" = {
              action = "find_files";
              options.desc = "Find project files";
            };
            "<leader>ff" = {
              action = "find_files hidden=true";
              options.desc = "Find project files";
            };
            "<leader>/" = {
              action = "live_grep";
              options.desc = "Grep (root dir)";
            };
            "<leader>:" = {
              action = "command_history";
              options.desc = "Command History";
            };
            "<leader>fr" = {
              action = "oldfiles";
              options.desc = "Recent";
            };
            "<c-p>" = {
              mode = [
                "n"
                "i"
              ];
              action = "registers";
              options.desc = "Select register to paste";
            };
            "<leader>gc" = {
              action = "git_commits";
              options.desc = "commits";
            };
            "<leader>sa" = {
              action = "autocommands";
              options.desc = "Auto Commands";
            };
            "<leader>sc" = {
              action = "commands";
              options.desc = "Commands";
            };
            "<leader>sd" = {
              action = "diagnostics bufnr=0";
              options.desc = "Workspace diagnostics";
            };
            "<leader>sh" = {
              action = "help_tags";
              options.desc = "Help pages";
            };
            "<leader>sk" = {
              action = "keymaps";
              options.desc = "Key maps";
            };
            "<leader>sM" = {
              action = "man_pages";
              options.desc = "Man pages";
            };
            "<leader>sm" = {
              action = "marks";
              options.desc = "Jump to Mark";
            };
            "<leader>so" = {
              action = "vim_options";
              options.desc = "Options";
            };
            "<leader>uC" = {
              action = "colorscheme";
              options.desc = "Colorscheme preview";
            };
          };
        };

        lsp-signature.enable = true;
        lint.enable = true;

        lsp = {
          enable = true;
          servers = {
            typos_lsp.enable = true;

            # Web
            cssls.enable = true;
            tailwindcss.enable = true;
            html.enable = true;
            svelte.enable = true;
            eslint.enable = true;
            ts_ls.enable = true;

            nixd.enable = true;
          };
        };

        lsp-format = {
          enable = true;
        };

        conform-nvim = {
          enable = true;
          settings = {
            formatters_by_ft = {
              javascript = ["prettierd"];
              javascriptreact = ["prettierd"];
              typescript = ["prettierd"];
              typescriptreact = ["prettierd"];
              svelte = ["prettierd"];

              nix = ["alejandra"];
            };

            format_on_save = {
              timeoutMs = 800;
              lspFallback = true;
            };
          };
        };

        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            incremental_selection.enable = true;
          };
          nixvimInjections = true;
        };

        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
            mapping = {
              "<C-d>" = "cmp.mapping.scroll_docs(-4)";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.close()";
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<C-y>" = "cmp.mapping.confirm({ select = true })";
            };

            sources = [
              {
                name = "nvim_lsp";
                priority = 100;
              }
              {
                name = "nvim_lsp_signature_help";
                priority = 100;
              }
              {
                name = "nvim_lsp_document_symbol";
                priority = 100;
              }
              {
                name = "treesitter";
                priority = 80;
              }
              # {
              #   name = "copilot";
              #   priority = 70;
              # }
              {
                name = "buffer";
                priority = 50;
                # Words from other open buffers can also be suggested.
                option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
                keywordLength = 3;
              }
              {
                name = "path";
                priority = 30;
              }
            ];
          };
        };
      };

      clipboard = {
        providers.wl-copy.enable = true;
        register = "unnamedplus";
      };

      opts = {
        updatetime = 50;
        timeoutlen = 250;
        signcolumn = "yes";
        termguicolors = true;

        relativenumber = true;
        number = true;

        swapfile = false;
        undofile = true;

        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        autoindent = true;
      };
    };

    starship = {
      enable = true;
      settings = {
      };
    };

    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [
      pkgs.hyprlandPlugins.hy3
      pkgs.hyprlandPlugins.hyprspace
    ];
    extraConfig = ''
      monitor = eDP-1, 2560x1600@165.00, auto, 1.333333, vrr, 1
      monitor = DP-2, 3440x1440@143.97, 1920x0, 1, vrr, 0
      monitor = desc:CVT VITURE 0x88888800, 1920x1080@120.00, 1600x0, 1, vrr, 1
      monitor = DP-5, preferred, auto-left, 2
      bindl = , switch:on:Lid Switch, exec, hyprctl keyword monitor "eDP-1, disable"

      bindl = , switch:off:Lid Switch, exec, hyprctl keyword monitor "eDP-1,2560x1600@165,0x0,1.333333"
      exec-once = waybar & swaync & hypridle
      exec-once = bash ~/.config/hypr/start.sh
      env = HYPRCURSOR_THEME,rose-pine-hyprcursor
      env = HYPRCURSOR_SIZE,24

      plugin {
        hy3 {
        }
      }

      render {
        explicit_sync = 1
        explicit_sync_kms = 1
      }

      input {
        # kb_layout = us
        kb_variant =
        kb_model =
        kb_options =
        kb_rules =
        follow_mouse = 1

        touchpad {
          natural_scroll = no
        }

        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      general {
        # gaps_out = 5
        # gaps_in = 2
        gaps_out = 0
        gaps_in = 0

        border_size = 0

        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)
        layout = hy3
      }

      decoration {

        rounding = 0

        blur {
          enabled = true
          size = 3
          passes = 1
        }

      }

      animations {
        enabled = false

        bezier = myBezier, 0.05, 0.9, 0.1, 1.05

        animation = windows, 1, 2, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 2, default
        animation = workspaces, 1, 2, default
      }

      workspace = w[t1], gapsout:0, gapsin:0
      workspace = w[tg1], gapsout:0, gapsin:0
      workspace = f[1], gapsout:0, gapsin:0
      windowrulev2 = bordersize 0, floating:0, onworkspace:w[t1]
      windowrulev2 = rounding 0, floating:0, onworkspace:w[t1]
      windowrulev2 = bordersize 0, floating:0, onworkspace:w[tg1]
      windowrulev2 = rounding 0, floating:0, onworkspace:w[tg1]
      windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
      windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

      dwindle {
        pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = yes # you probably want this
      }

      master {
      }

      gestures {
        workspace_swipe = off
      }

      misc {
        force_default_wallpaper = -1 # Set to 0 to disable the anime mascot wallpapers
        vrr = 1
      }
      $mainMod = SUPER
      $browser = zen-beta

      bind = $mainMod, T, exec, ghostty
      bind = $mainMod, Q, killactive,
      bind = $mainMod, E, exec, nautilus
      bind = $mainMod, W, togglefloating,
      bind = $mainMod, G, exec, pkill -SIGUSR1 waybar
      bind = $mainMod, A, exec, /home/yvesd/Nixos/Configuration/Configs/rofi/scripts/main-menu.sh
      bind = $mainMod, S, exec, /home/yvesd/Nixos/Configuration/Configs/rofi/scripts/uni-search.sh

      # Browser stuff
      bind = $mainMod, F, exec, $browser
      bind = $mainMod, H, exec, $browser --private-window # Private Window
      bind = $mainMod, Y, exec, $browser --new-window https://www.youtube.com/feed/subscriptions
      bind = $mainMod, U, exec, $browser --new-window https://slate.sheridancollege.ca/d2l/login
      bind = $mainMod, N, exec,
      bind = $mainMod, O, overview:toggle

      bind = $mainMod, D, exec, moonlight
      bind = $mainMod, V, hy3:makegroup, v, ephemeral
      bind = $mainMod, M, hy3:makegroup, tab, ephemeral
      bind = $mainMod SHIFT, M, hy3:makegroup, tab, force_ephemeral

      bind = $mainMod, B, togglespecialworkspace
      bind = $mainMod, C, exec,
      bind = $mainMod, L, exec, hyprlock
      bind = $mainMod, P, exec, grim -g "$(slurp -d)" - | wl-copy

      windowrulev2 = workspace 10,DP-2 class:^(spotify)$
      windowrulev2 = workspace 9,DP-2 class:^(discord)$

      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, hy3:movefocus, l
      bind = $mainMod, right, hy3:movefocus, r
      bind = $mainMod, up, hy3:movefocus, u
      bind = $mainMod, down, hy3:movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Resize windows
      binde = $mainMod SHIFT, right, resizeactive, 30 0
      binde = $mainMod SHIFT, left, resizeactive, -30 0
      binde = $mainMod SHIFT, up, resizeactive, 0 -30
      binde = $mainMod SHIFT, down, resizeactive, 0 30

    '';
  };

  programs.home-manager.enable = true;
}
