{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./modules/hyprland.nix
    ./modules/zed-editor.nix
  ];
  
  home = {
    username = "yvesd";
    homeDirectory = "/home/yvesd";
    stateVersion = "25.05";
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
      '';
      shellAliases = {
        update = "sudo nixos-rebuild switch";
        clean = "sudo nix-collect-garbage -d";
        ai = "~/Codingspace/Rust/code/cargo/Client-api/target/debug/Client-api";
        c = "cd";
        h = "hx";
      };

    };

    ghostty = {
      enable = true;
      settings = {
        theme = "tokyonight_moon";
        keybind = [
          "ctrl+v=paste_from_clipboard"
          "ctrl+y=copy_to_clipboard"
          "ctrl+1=decrease_font_size:1"
          "ctrl+2=increase_font_size:1"
          "ctrl+r=reset_font_size"
        ];
      };
    };
    
    helix = {
      enable = true;
      settings = {
        theme = "tokyonight_moon";
        editor = {
          line-number = "relative";
          lsp.display-messages = true;
          cursor-shape = {
            insert = "bar";
          };
          indent-guides = {
            render = true;
            character = "╎";
            skip-levels = 1;
          };
        };
      };
    };

    # nixvim = {
    #   enable = true;
    #   enableMan = true;
    #   defaultEditor = true;
    #   viAlias = true;
    #   vimAlias = true;
    #   luaLoader.enable = true;

    #   globals = {
    #     mapleader = " ";
    #     maplocalleader = " ";
    #   };

    #   colorschemes.tokyonight = {
    #     enable = true;
    #     settings.style = "night";
    #   };

    #   plugins = {
    #     alpha = {
    #       enable = true;
    #       theme = "dashboard";
    #     };

    #     vimtex = {
    #       enable = true;
    #     };

    #     lualine = {
    #       enable = true;
    #     };

    #     which-key = {
    #       enable = true;
    #     };

    #     gitsigns = {
    #       enable = true;
    #     };

    #     web-devicons = {
    #       enable = true;
    #     };

    #     indent-blankline = {
    #       enable = true;
    #     };

    #     notify = {
    #       enable = true;
    #     };

    #     # avante = {
    #     #   enable = true;
    #     #   settings = {
    #     #     provider = "copilot";
    #     #   };
    #     # };

    #     telescope = {
    #       enable = true;
    #       extensions = {
    #         fzf-native.enable = true;
    #         undo.enable = true;
    #       };

    #       settings.defaults = {
    #         prompt_prefix = "   ";
    #         color_devicons = true;
    #         set_env.COLORTERM = "truecolor";

    #         mappings = {
    #           i = {
    #             "<esc>".__raw = ''
    #               function(...)
    #                 return require("telescope.actions").close(...)
    #               end'';
    #             "<c-t>".__raw = ''
    #               function(...)
    #                 require('trouble.providers.telescope').open_with_trouble(...);
    #               end
    #             '';
    #           };
    #           n = {
    #             "<c-t>".__raw = ''
    #               function(...)
    #                 require('trouble.providers.telescope').open_with_trouble(...);
    #               end
    #             '';
    #           };
    #         };
    #         # trim leading whitespace from grep
    #         vimgrep_arguments = [
    #           "${pkgs.ripgrep}/bin/rg"
    #           "--color=never"
    #           "--no-heading"
    #           "--with-filename"
    #           "--line-number"
    #           "--column"
    #           "--smart-case"
    #           "--trim"
    #         ];
    #       };

    #       keymaps = {
    #         "<leader>fp" = {
    #           action = "projects";
    #           options.desc = "Search Todo";
    #         };
    #         "<leader>st" = {
    #           action = "todo-comments";
    #           options.desc = "Search Todo";
    #         };
    #         "<leader>sn" = {
    #           action = "notify";
    #           options.desc = "Search Notifications";
    #         };
    #         "<leader>su" = {
    #           action = "undo";
    #           options.desc = "Search Undo";
    #         };
    #         "<leader><space>" = {
    #           action = "find_files";
    #           options.desc = "Find project files";
    #         };
    #         "<leader>ff" = {
    #           action = "find_files hidden=true";
    #           options.desc = "Find project files";
    #         };
    #         "<leader>/" = {
    #           action = "live_grep";
    #           options.desc = "Grep (root dir)";
    #         };
    #         "<leader>:" = {
    #           action = "command_history";
    #           options.desc = "Command History";
    #         };
    #         "<leader>fr" = {
    #           action = "oldfiles";
    #           options.desc = "Recent";
    #         };
    #         "<c-p>" = {
    #           mode = [
    #             "n"
    #             "i"
    #           ];
    #           action = "registers";
    #           options.desc = "Select register to paste";
    #         };
    #         "<leader>gc" = {
    #           action = "git_commits";
    #           options.desc = "commits";
    #         };
    #         "<leader>sa" = {
    #           action = "autocommands";
    #           options.desc = "Auto Commands";
    #         };
    #         "<leader>sc" = {
    #           action = "commands";
    #           options.desc = "Commands";
    #         };
    #         "<leader>sd" = {
    #           action = "diagnostics bufnr=0";
    #           options.desc = "Workspace diagnostics";
    #         };
    #         "<leader>sh" = {
    #           action = "help_tags";
    #           options.desc = "Help pages";
    #         };
    #         "<leader>sk" = {
    #           action = "keymaps";
    #           options.desc = "Key maps";
    #         };
    #         "<leader>sM" = {
    #           action = "man_pages";
    #           options.desc = "Man pages";
    #         };
    #         "<leader>sm" = {
    #           action = "marks";
    #           options.desc = "Jump to Mark";
    #         };
    #         "<leader>so" = {
    #           action = "vim_options";
    #           options.desc = "Options";
    #         };
    #         "<leader>uC" = {
    #           action = "colorscheme";
    #           options.desc = "Colorscheme preview";
    #         };
    #       };
    #     };

    #     lsp-signature.enable = true;
    #     lint.enable = true;

    #     lsp = {
    #       enable = true;
    #       servers = {
    #         typos_lsp.enable = true;

    #         # Web
    #         cssls.enable = true;
    #         tailwindcss.enable = true;
    #         html.enable = true;
    #         svelte.enable = true;
    #         eslint.enable = true;
    #         ts_ls.enable = true;
    #         pyright.enable = true;

    #         nixd.enable = true;
    #       };
    #     };

    #     lsp-format = {
    #       enable = true;
    #     };

    #     conform-nvim = {
    #       enable = true;
    #       settings = {
    #         formatters_by_ft = {
    #           javascript = ["prettierd"];
    #           javascriptreact = ["prettierd"];
    #           typescript = ["prettierd"];
    #           typescriptreact = ["prettierd"];
    #           svelte = ["prettierd"];

    #           nix = ["alejandra"];
    #         };

    #         format_on_save = {
    #           timeoutMs = 800;
    #           lspFallback = true;
    #         };
    #       };
    #     };

    #     treesitter = {
    #       enable = true;
    #       settings = {
    #         highlight.enable = true;
    #         incremental_selection.enable = true;
    #       };
    #       nixvimInjections = true;
    #     };

    #     cmp = {
    #       enable = true;
    #       autoEnableSources = true;
    #       settings = {
    #         mapping = {
    #           "<C-d>" = "cmp.mapping.scroll_docs(-4)";
    #           "<C-f>" = "cmp.mapping.scroll_docs(4)";
    #           "<C-Space>" = "cmp.mapping.complete()";
    #           "<C-e>" = "cmp.mapping.close()";
    #           "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
    #           "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
    #           "<C-y>" = "cmp.mapping.confirm({ select = true })";
    #         };

    #         sources = [
    #           {
    #             name = "nvim_lsp";
    #             priority = 100;
    #           }
    #           {
    #             name = "nvim_lsp_signature_help";
    #             priority = 100;
    #           }
    #           {
    #             name = "nvim_lsp_document_symbol";
    #             priority = 100;
    #           }
    #           {
    #             name = "treesitter";
    #             priority = 80;
    #           }
    #           # {
    #           #   name = "copilot";
    #           #   priority = 70;
    #           # }
    #           {
    #             name = "buffer";
    #             priority = 50;
    #             # Words from other open buffers can also be suggested.
    #             option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
    #             keywordLength = 3;
    #           }
    #           {
    #             name = "path";
    #             priority = 30;
    #           }
    #         ];
    #       };
    #     };
    #   };

    #   clipboard = {
    #     providers.wl-copy.enable = true;
    #     register = "unnamedplus";
    #   };

    #   opts = {
    #     updatetime = 50;
    #     timeoutlen = 250;
    #     signcolumn = "yes";
    #     termguicolors = true;

    #     relativenumber = true;
    #     number = true;

    #     swapfile = false;
    #     undofile = true;

    #     tabstop = 2;
    #     shiftwidth = 2;
    #     expandtab = true;
    #     autoindent = true;
    #   };
    # };

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
