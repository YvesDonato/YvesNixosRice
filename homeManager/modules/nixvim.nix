{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
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
      settings.style = "storm";
    };

    performance = {
      byteCompileLua.enable = true;
    };

    plugins = {
      alpha = {
        enable = true;
        theme = "dashboard";
      };

      web-devicons = {
        enable = true;
      };

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
        };
      };

      which-key = {
        enable = true;
      };

      gitsigns = {
        enable = true;
      };

      comment = {
        enable = true;
      };

      indent-blankline = {
        enable = true;
        settings = {
          indent = {
            char = "╎";
          };
        };
      };

      intellitab = {
        enable = true;
      };

      yanky = {
        enable = true;
      };

      telescope = {
        enable = true;
        extensions = {
          file-browser = {
            enable = true;
            settings = {
              hijack_netrw = true;
              depth = 1;
            };
          };

          undo = {
            enable = true;
          };

          live-grep-args = {
            enable = true;
          };

          fzf-native = {
            enable = true;
          };
        };

        keymaps = {
          "<leader>ff" = "file_browser";
          "<leader>fg" = "live_grep";
          "<leader>fs" = "find_files";
          "<leader>u" = "undo";
        };
      };

      lualine = {
        enable = true;
      };

      lsp = {
        servers = {
          copilot.enable = true;
          nixd.enable = true;
          basedpyright.enable = true;
          html.enable = true;
          svelte.enable = true;
          tailwindcss = {
            enable = true;
            filetypes = ["svelte"];
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          mapping = {
            # "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            # "<C-f>" = "cmp.mapping.scroll_docs(4)";
            # "<leader><CR>" = "cmp.mapping.complete()";
            # "<C-e>" = "cmp.mapping.close()";
            "<Esc>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.abort() else fallback() end end, {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            # "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<S-CR>" = "cmp.mapping.confirm({ select = true })";
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
            {
              name = "copilot";
              priority = 70;
            }
            {
              name = "buffer";
              priority = 50;
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

    keymaps = [
      {
        mode = "n"; # Normal mode
        key = "U"; # Shift + u
        action = "<C-r>"; # The original Redo command
        options = {
          desc = "Redo";
        };
      }
    ];
  };
}
