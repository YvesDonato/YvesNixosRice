{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {

  imports = [
  ];
  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;
    extensions = [ "nix" "toml" "rust" ];
    extraPackages = [ pkgs.nixd pkgs.nil ];
    userSettings = {
      theme = {
        mode = "dark";
        dark = "Tokyo Night Storm";
        light = "One Light";
      };

      hour_format = "hour12";
      helix_mode = true;
      vim_mode = true;
      relative_line_numbers = true;
      tab_bar = {
        show = true;
      };
      title_bar = {
        show_branch_icon = false;
        show_user_picture = false;
        show_sign_in = false;
        show_menus = false;
      };
      # AI
      features = {
        edit_prediction_provider = "copilot";
      };
      # agent = {
      #   default_model = {
      #     provider = "anthropic";
      #     model = "claude-4-5-sonnet";
      #   };
      # };
    };
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
  };
}
