{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [];

  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;

    # This populates the userSettings "auto_install_extensions".
    extensions = ["nix" "toml" "rust" "elixir" "make"];
    extraPackages = [pkgs.nixd pkgs.nil];

    # userKeymaps = [
    #   {
    #     context = "Editor && (vim_mode == normal || vim_mode == visual)";
    #     bindings = {
    #       "space g h d" = "editor::ToggleHunkDiff";
    #       "space g h r" = "editor::RevertSelectedHunks";
    #       "space t i" = "editor::ToggleInlayHints";
    #       "space u w" = "editor::ToggleSoftWrap";
    #       "space c z" = "workspace::ToggleCenteredLayout";
    #       "space m p" = "markdown::OpenPreview";
    #       "space m P" = "markdown::OpenPreviewToTheSide";
    #       "space f p" = "projects::OpenRecent";
    #       "space f m" = "editor::Format";
    #       "space f M" = "editor::FormatSelections";
    #       "space s w" = "pane::DeploySearch";
    #       "space a c" = "assistant::ToggleFocus";
    #       "g f" = "editor::OpenExcerpts";
    #     };
    #   }
    # ];

    userSettings = {
      assistant = {
        enabled = true;
        version = "2";
        default_open_ai_model = null;

        default_model = {
          provider = "zed.dev";
          model = "claude-3-5-sonnet-latest";
        };
      };

      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      hour_format = "hour24";
      auto_update = false;
      helix_mode = true;
      vim_mode = true;
      relative_line_numbers = true;
      load_direnv = "shell_hook";
      base_keymap = "VSCode";
      show_whitespaces = "all";
      ui_font_size = 16;
      buffer_font_size = 16;

      features = {
        edit_prediction_provider = "copilot";
      };

      tab_bar = {
        show = true;
      };

      title_bar = {
        show_branch_icon = false;
        show_user_picture = false;
        show_sign_in = false;
        show_menus = false;
      };

      terminal = {
        alternate_scroll = "off";
        blinking = "off";
        copy_on_select = false;
        dock = "bottom";
        detect_venv = {
          on = {
            directories = [".env" "env" ".venv" "venv"];
            activate_script = "default";
          };
        };
        env = {
          TERM = "alacritty";
        };
        font_family = "FiraCode Nerd Font";
        font_features = null;
        font_size = null;
        line_height = "comfortable";
        option_as_meta = false;
        button = false;
        shell = "system";
        toolbar = {
          title = true;
        };
        working_directory = "current_project_directory";
      };

      lsp = {
        rust-analyzer = {
          binary = {
            path_lookup = true;
          };
        };

        nix = {
          binary = {
            path_lookup = true;
          };
        };

        elixir-ls = {
          binary = {
            path_lookup = true;
          };
          settings = {
            dialyzerEnabled = true;
          };
        };
      };

      languages = {
        "Elixir" = {
          language_servers = ["!lexical" "elixir-ls" "!next-ls"];
          format_on_save = {
            external = {
              command = "mix";
              arguments = ["format" "--stdin-filename" "{buffer_path}" "-"];
            };
          };
        };

        "HEEX" = {
          language_servers = ["!lexical" "elixir-ls" "!next-ls"];
          format_on_save = {
            external = {
              command = "mix";
              arguments = ["format" "--stdin-filename" "{buffer_path}" "-"];
            };
          };
        };
      };

      theme = {
        mode = "system";
        light = "One Light";
        dark = "Tokyo Night Storm";
      };
    };
  };
}
