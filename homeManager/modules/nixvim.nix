{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: let
  codelldbAdapter = pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter;
in {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    # Reuse the host pkgs for nixvim's plugin set: nixvim otherwise imports its
    # own nixpkgs instance without our allowUnfree, which rejects the (since
    # 26.05) unfree-flagged cmp-nvim-lsp-document-symbol. Also avoids a whole
    # extra nixpkgs evaluation.
    nixpkgs.pkgs = pkgs;
    enableMan = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    luaLoader.enable = true;

    extraPackages = [
      pkgs.clang-tools
      codelldbAdapter
      # conform-nvim's configured formatters; keep them explicit so
      # format-on-save can't silently lose their binaries.
      # (top-level attr since 26.05 removed the nodePackages set)
      pkgs-unstable.prettier
      pkgs-unstable.typstyle
    ];

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
        # Native nixvim option (26.05). Its `disable` only takes language
        # names, so the size-based opt-out lives in the large-file autocmd
        # below (vim.treesitter.stop), matching the old disable-function.
        highlight.enable = true;
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
          clangd = {
            enable = true;
            package = pkgs.clang-tools;
          };
          cssls.enable = true;
          eslint.enable = true;
          html.enable = true;
          jsonls.enable = true;
          marksman.enable = true;
          nixd.enable = true;
          svelte.enable = true;
          tailwindcss = {
            enable = true;
            filetypes = [
              "css"
              "html"
              "javascript"
              "javascript.jsx"
              "javascriptreact"
              "svelte"
              "typescript"
              "typescript.tsx"
              "typescriptreact"
            ];
          };
          tinymist = {
            enable = true;
            package = pkgs-unstable.tinymist;
          };
          ts_ls.enable = true;
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            css = ["prettier"];
            html = ["prettier"];
            javascript = ["prettier"];
            "javascript.jsx" = ["prettier"];
            javascriptreact = ["prettier"];
            json = ["prettier"];
            jsonc = ["prettier"];
            markdown = ["prettier"];
            typescript = ["prettier"];
            "typescript.tsx" = ["prettier"];
            typescriptreact = ["prettier"];
            typst = ["typstyle"];
          };
          format_on_save = {
            lsp_format = "never";
            timeout_ms = 2000;
          };
          notify_no_formatters = false;
        };
      };

      dap = {
        enable = true;
      };

      dap-lldb = {
        enable = true;
        settings = {
          codelldb_path = "${codelldbAdapter}/bin/codelldb";
          configurations = {
            c = [
              {
                name = "Debug C executable";
                type = "lldb";
                request = "launch";
                program.__raw = ''
                  function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                  end
                '';
                cwd = "\${workspaceFolder}";
                stopOnEntry = false;
              }
            ];
          };
        };
      };

      dap-ui = {
        enable = true;
      };

      dap-virtual-text = {
        enable = true;
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
      -- Force `.typ` files to the typst filetype so tinymist always attaches
      -- (content-based detection can misfire on new/empty documents).
      vim.filetype.add({ extension = { typ = "typst" } })

      -- Disable treesitter highlighting on large files (the 26.05 native
      -- treesitter option no longer accepts a disable function).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          if vim.b[args.buf].large_file then
            pcall(vim.treesitter.stop, args.buf)
          end
        end,
      })

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

      local dap_ok, dap = pcall(require, "dap")
      local dapui_ok, dapui = pcall(require, "dapui")
      if dap_ok and dapui_ok then
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
      end
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
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options = {
          desc = "Show diagnostic";
        };
      }
      {
        mode = "n";
        key = "<leader>cf";
        action = "<cmd>lua require('conform').format({ async = true, lsp_format = 'never' })<CR>";
        options = {
          desc = "Format buffer";
        };
      }
      {
        mode = "n";
        key = "<leader>dc";
        action = "<cmd>lua require('dap').continue()<CR>";
        options = {
          desc = "Debug continue";
        };
      }
      {
        mode = "n";
        key = "<leader>db";
        action = "<cmd>lua require('dap').toggle_breakpoint()<CR>";
        options = {
          desc = "Debug breakpoint";
        };
      }
      {
        mode = "n";
        key = "<leader>di";
        action = "<cmd>lua require('dap').step_into()<CR>";
        options = {
          desc = "Debug step into";
        };
      }
      {
        mode = "n";
        key = "<leader>do";
        action = "<cmd>lua require('dap').step_over()<CR>";
        options = {
          desc = "Debug step over";
        };
      }
      {
        mode = "n";
        key = "<leader>dO";
        action = "<cmd>lua require('dap').step_out()<CR>";
        options = {
          desc = "Debug step out";
        };
      }
      {
        mode = "n";
        key = "<leader>dt";
        action = "<cmd>lua require('dap').terminate()<CR>";
        options = {
          desc = "Debug terminate";
        };
      }
      {
        mode = "n";
        key = "<leader>dr";
        action = "<cmd>lua require('dap').repl.toggle()<CR>";
        options = {
          desc = "Debug REPL";
        };
      }
      {
        mode = "n";
        key = "<leader>du";
        action = "<cmd>lua require('dapui').toggle()<CR>";
        options = {
          desc = "Debug UI";
        };
      }
    ];
  };
}
