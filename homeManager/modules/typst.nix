{
  pkgs,
  pkgs-unstable,
  ...
}: let
  typst-edit = pkgs.writeShellApplication {
    name = "typst-edit";
    # zellij MUST match programs.zellij (pkgs-unstable.zellij) or `zellij action`
    # fails on a server/client version mismatch. typst matches the system CLI.
    runtimeInputs = [
      pkgs-unstable.typst
      pkgs-unstable.zellij
      pkgs.zathura
      pkgs.coreutils
    ];
    text = ''
      if [ "$#" -ne 1 ]; then
        echo "usage: typst-edit <file.typ>" >&2
        exit 1
      fi

      src="$1"
      case "$src" in
        *.typ) ;;
        *) echo "typst-edit: expected a .typ file, got '$src'" >&2; exit 1 ;;
      esac

      src="$(realpath "$src")"
      pdf="''${src%.typ}.pdf"

      # First compile so the preview has a PDF to open. Ignore errors —
      # `typst watch` keeps retrying once the editor is up.
      typst compile "$src" || true

      # Live PDF preview in its own window; zathura auto-reloads on recompile.
      # nohup + & so it outlives this launcher and the WM tiles it beside zellij.
      if [ -f "$pdf" ]; then
        nohup zathura "$pdf" >/dev/null 2>&1 &
      fi

      # Editor + watch loop in a zellij layout. zellij can't take a runtime
      # filename, so generate a temp layout with the path baked in.
      layout="$(mktemp --suffix=.kdl)"
      trap 'rm -f "$layout"' EXIT
      cat > "$layout" <<KDL
      layout {
          pane split_direction="horizontal" {
              pane command="nvim" focus=true {
                  args "$src"
              }
              pane command="typst" size="20%" {
                  args "watch" "$src"
              }
          }
      }
      KDL

      if [ -n "''${ZELLIJ:-}" ]; then
        zellij action new-tab --layout "$layout" --name typst
      else
        zellij --layout "$layout"
      fi
    '';
  };
in {
  programs.zathura = {
    enable = true;
    # Manual TokyoNight, matching the repo's theming convention. Auto-reload is
    # on by default (zathura watches the file), so no extra option is needed.
    options = {
      default-bg = "#222436";
      default-fg = "#c8d3f5";
      statusbar-bg = "#1e2030";
      statusbar-fg = "#c8d3f5";
      inputbar-bg = "#1e2030";
      inputbar-fg = "#c8d3f5";
      highlight-color = "#ffc777";
      highlight-active-color = "#ff966c";
      selection-clipboard = "clipboard";
    };
  };

  home.packages = [typst-edit];
}
