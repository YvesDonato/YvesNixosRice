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

      # Skip provider probes for runtimes this config does not use.
      loaded_node_provider = 0;
      loaded_perl_provider = 0;
      loaded_python3_provider = 0;
      loaded_ruby_provider = 0;

      # Telescope file-browser replaces netrw.
      loaded_netrw = 1;
      loaded_netrwPlugin = 1;
    };

    colorschemes.tokyonight = {
      enable = true;
      settings.style = "storm";
    };

    performance = {
      byteCompileLua.enable = true;
      byteCompileLua.plugins = true;
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
          highlight = {
            enable = true;
            disable.__raw = ''
              function(_, bufnr)
                local max_filesize = 200 * 1024
                local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(bufnr))
                return ok and stats and stats.size > max_filesize
              end
            '';
          };
        };
      };

      which-key = {
        enable = true;
      };

      gitsigns = {
        enable = true;
        settings = {
          attach_to_untracked = false;
          max_file_length = 2000;
          on_attach.__raw = ''
            function(bufnr)
              return not vim.b[bufnr].large_file
            end
          '';
        };
      };

      comment = {
        enable = true;
      };

      indent-blankline = {
        enable = true;
        settings = {
          exclude = {
            buftypes = [
              "nofile"
              "prompt"
              "quickfix"
              "terminal"
            ];
            filetypes = [
              "alpha"
              "dashboard"
              "help"
              "TelescopePrompt"
            ];
          };
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
        settings = {
          defaults = {
            file_ignore_patterns = [
              "%.git/"
              "%.direnv/"
              "%.next/"
              "%.svelte%-kit/"
              "build/"
              "dist/"
              "node_modules/"
              "result$"
              "target/"
            ];
            path_display = ["truncate"];
            vimgrep_arguments = [
              "rg"
              "--color=never"
              "--no-heading"
              "--with-filename"
              "--line-number"
              "--column"
              "--smart-case"
              "--glob"
              "!{.git,node_modules,.direnv,.next,.svelte-kit,build,dist,target}/**"
              "--glob"
              "!result"
            ];
          };
          pickers.find_files.hidden = true;
        };
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
          "<leader>fg" = "live_grep_args";
          "<leader>fs" = "find_files";
          "<leader>u" = "undo";
        };
      };

      lualine = {
        enable = true;
      };

      lsp = {
        enable = true;
        servers = {
          basedpyright.enable = true;
          html.enable = true;
          marksman.enable = true;
          nixd.enable = true;
          svelte.enable = true;
          tailwindcss = {
            enable = true;
            filetypes = ["svelte"];
          };
          ts_ls.enable = true;
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          completion.keyword_length = 2;
          enabled.__raw = ''
            function()
              return vim.bo.buftype ~= "prompt" and not vim.b.large_file
            end
          '';
          mapping = {
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Esc>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.abort() else fallback() end end, {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<S-CR>" = "cmp.mapping.confirm({ select = true })";
          };
          sources = [
            {
              name = "nvim_lsp";
              keyword_length = 2;
              priority = 100;
            }
            {
              name = "nvim_lsp_signature_help";
              priority = 90;
            }
            {
              name = "nvim_lsp_document_symbol";
              keyword_length = 4;
              priority = 60;
            }
            {
              name = "treesitter";
              keyword_length = 4;
              priority = 50;
            }
            {
              name = "copilot";
              keyword_length = 3;
              priority = 40;
            }
            {
              name = "buffer";
              keyword_length = 3;
              priority = 30;
              option.get_bufnrs.__raw = ''
                function()
                  local bufs = {}
                  for _, win in ipairs(vim.api.nvim_list_wins()) do
                    bufs[vim.api.nvim_win_get_buf(win)] = true
                  end
                  return vim.tbl_keys(bufs)
                end
              '';
            }
            {
              name = "path";
              keyword_length = 2;
              priority = 20;
            }
          ];
          performance = {
            debounce = 60;
            fetching_timeout = 200;
            max_view_entries = 50;
            throttle = 30;
          };
        };
      };
    };

    extraConfigLua = ''
      vim.api.nvim_create_autocmd({ "BufReadPre", "FileReadPre" }, {
        callback = function(args)
          local max_filesize = 200 * 1024
          local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(args.buf))
          if ok and stats and stats.size > max_filesize then
            vim.b[args.buf].large_file = true
            vim.opt_local.foldmethod = "manual"
            vim.opt_local.spell = false
            vim.opt_local.swapfile = false
          end
        end,
      })
    '';

    clipboard = {
      providers.wl-copy.enable = true;
      register = "unnamedplus";
    };

    opts = {
      updatetime = 250;
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
