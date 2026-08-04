{
  lib,
  pkgs,
  pkgs-unstable,
  inputs,
  desktopWindowManager,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  mangowcPatched = pkgs-unstable.callPackage ../../packages/mango-patched.nix {
    mango = inputs.mango.packages.${system}.default;
  };
  systemdRun = lib.getExe' pkgs.systemd "systemd-run";
  vesktop = lib.getExe pkgs-unstable.vesktop;
  spotify = lib.getExe pkgs-unstable.spotify;
  ghostty = lib.getExe pkgs-unstable.ghostty;
  herdr = lib.getExe inputs.herdr.packages.${system}.default;
  wlrRandr = lib.getExe pkgs.wlr-randr;
  laptopOutput = "eDP-1";
  laptopMode = "2560x1600@165.002Hz";
  laptopPosition = "3440,0";
  laptopScale = "1.333333";
  enableLaptopPanel = "${wlrRandr} --output ${laptopOutput} --on --mode ${laptopMode} --pos ${laptopPosition} --scale ${laptopScale}";
  restoreMonitors = "${wlrRandr} --output DP-2 --mode 3440x1440@143.975Hz --pos 0,0 --scale 1 --output ${laptopOutput} --on --mode ${laptopMode} --pos ${laptopPosition} --scale ${laptopScale}";
  mmsg = "${mangowcPatched}/bin/mmsg";
  qs = "qs";
  mangoScrollerMinProportion = "0.333333";
  mangoCycleLayouts = [
    "scroller"
    "tile"
    "center_tile"
    "grid"
  ];
  mangoSupportedLayouts = [
    "scroller"
    "tile"
    "grid"
    "monocle"
    "deck"
    "center_tile"
    "right_tile"
    "vertical_scroller"
    "vertical_tile"
    "vertical_grid"
    "vertical_deck"
    "dwindle"
    "fair"
    "vertical_fair"
  ];
  # ALL built-in layouts in mango's layouts[] array order — mmsg reports the
  # current layout as a 0-based index into this array, and the Super+Shift+Tab
  # cycle-all script maps through it. Keep in sync with src/layout/layout.h
  # when bumping mango.
  mangoAllLayouts = [
    "tile"
    "scroller"
    "grid"
    "monocle"
    "deck"
    "center_tile"
    "right_tile"
    "vertical_scroller"
    "vertical_tile"
    "vertical_grid"
    "vertical_deck"
    "dwindle"
    "fair"
    "vertical_fair"
  ];
  unsupportedMangoCycleLayouts = lib.filter (layout: !(builtins.elem layout mangoSupportedLayouts)) mangoCycleLayouts;
  mangoCycleLayoutConfig = lib.concatStringsSep "," mangoCycleLayouts;

  mangoRestoreMonitors = pkgs.writeShellApplication {
    name = "mango-restore-monitors";
    runtimeInputs = [
      mangowcPatched
      pkgs.wlr-randr
    ];
    text = ''
      ${restoreMonitors}
      mmsg dispatch reload_config
    '';
  };

  mangoCycleAllLayouts = pkgs.writeShellApplication {
    name = "mango-cycle-all-layouts";
    runtimeInputs = [
      pkgs.jq
      mangowcPatched
    ];
    text = ''
      # Super+Shift+Tab cycles all built-in layouts. mangoAllLayouts mirrors
      # Mango's layouts[] order and layout_index is zero-based.
      layouts=(${lib.concatMapStringsSep " " (layout: lib.escapeShellArg layout) mangoAllLayouts})
      count="''${#layouts[@]}"
      idx="$(mmsg get all-monitors | jq -er '
        first(
          .monitors[]?
          | select(.active == true)
          | .layout_index
          | select(type == "number")
        )
      ')"
      next=$(((idx + 1) % count))
      exec mmsg dispatch "setlayout,''${layouts[$next]}"
    '';
  };

  mangoApplyLidState = pkgs.writeShellApplication {
    name = "mango-apply-lid-state";
    runtimeInputs = [
      mangowcPatched
      pkgs.wlr-randr
    ];
    text = ''
      state="''${1:-}"

      case "$state" in
        closed)
          ${wlrRandr} --output ${laptopOutput} --off || mmsg dispatch disable_monitor,${laptopOutput} || true
          ;;
        open)
          ${enableLaptopPanel} || mmsg dispatch enable_monitor,${laptopOutput} || true
          ;;
        *)
          printf 'usage: %s open|closed\n' "$0" >&2
          exit 2
          ;;
      esac
    '';
  };

  mangoLidSwitchWatch = pkgs.writeShellApplication {
    name = "mango-lid-switch-watch";
    runtimeInputs = [
      pkgs.coreutils
      mangoApplyLidState
    ];
    text = ''
      lid_state_path="''${LID_STATE_PATH:-}"

      if [ -z "$lid_state_path" ]; then
        for candidate in /proc/acpi/button/lid/*/state; do
          if [ -r "$candidate" ]; then
            lid_state_path="$candidate"
            break
          fi
        done
      fi

      if [ -z "$lid_state_path" ] || [ ! -r "$lid_state_path" ]; then
        printf 'No readable ACPI lid state file found\n' >&2
        exit 0
      fi

      read_lid_state() {
        local line
        IFS= read -r line <"$lid_state_path" || {
          printf 'unknown\n'
          return
        }

        case "$line" in
          *closed*) printf 'closed\n' ;;
          *open*) printf 'open\n' ;;
          *) printf 'unknown\n' ;;
        esac
      }

      last_state="$(read_lid_state)"
      if [ "$last_state" = "closed" ]; then
        mango-apply-lid-state closed
      fi

      while :; do
        state="$(read_lid_state)"
        if [ "$state" != "$last_state" ]; then
          case "$state" in
            open | closed) mango-apply-lid-state "$state" ;;
          esac
          last_state="$state"
        fi
        sleep 1
      done
    '';
  };

  mangoHerdr = pkgs.writeShellApplication {
    name = "mango-herdr";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.util-linux
      mangowcPatched
    ];
    text = ''
      mode="''${1:-open}"
      case "$mode" in
        open | preload) ;;
        *)
          printf 'usage: %s open|preload\n' "$0" >&2
          exit 2
          ;;
      esac

      lock_file="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/mango-herdr.lock"
      exec 9>"$lock_file"
      flock 9

      clients="$(mmsg get all-clients)"
      if ! jq -e 'any(.clients[]?; .appid == "com.yvesd.herdr")' <<<"$clients" >/dev/null; then
        ${systemdRun} --user --scope --quiet --collect -- ${ghostty} --class=com.yvesd.herdr -e ${herdr} 9>&- </dev/null >/dev/null &
      fi

      for _ in {1..100}; do
        if mmsg get all-clients | jq -e 'any(.clients[]?; .appid == "com.yvesd.herdr" and ((.tags // []) | index(11) != null))' >/dev/null; then
          if [ "$mode" = "open" ]; then
            exec mmsg dispatch view,11,0
          fi
          exit 0
        fi
        sleep 0.1
      done

      printf 'Timed out waiting for Herdr on Mango tag 11\n' >&2
      exit 1
    '';
  };

  mangoSessionStart = pkgs.writeShellApplication {
    name = "mango-session-start";
    runtimeInputs = [
      pkgs.dbus
      pkgs.systemd
    ];
    text = ''
      export XDG_CURRENT_DESKTOP="''${XDG_CURRENT_DESKTOP:-mango}"
      export XDG_SESSION_DESKTOP="''${XDG_SESSION_DESKTOP:-mango}"
      export XDG_SESSION_TYPE="''${XDG_SESSION_TYPE:-wayland}"
      export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-wayland}"

      variables=()
      for variable in DISPLAY QT_QPA_PLATFORM WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE; do
        if [[ -v "$variable" ]]; then
          variables+=("$variable")
        fi
      done

      if ((''${#variables[@]} > 0)); then
        systemctl --user import-environment "''${variables[@]}"
        dbus-update-activation-environment --systemd "''${variables[@]}"
      fi

      # graphical-session.target refuses direct manual starts. Starting the
      # compositor target pulls it in through BindsTo, as Home Manager's
      # native Hyprland integration does.
      systemctl --user start mango-session.target
    '';
  };

  mangoConfig = ''
    # Generated by the Home Manager Mango module.

    # Window effects
    blur=0
    blur_layer=0
    blur_optimized=1
    shadows=0
    layer_shadows=0
    shadow_only_floating=1
    border_radius=0
    no_radius_when_single=1
    focused_opacity=1.0
    unfocused_opacity=1.0

    # Animation
    animations=0
    layer_animations=0

    # Scroller layout
    scroller_structs=20
    scroller_default_proportion=${mangoScrollerMinProportion}
    scroller_focus_center=0
    scroller_prefer_center=0
    edge_scroller_pointer_focus=1
    scroller_default_proportion_single=1.0
    scroller_proportion_preset=${mangoScrollerMinProportion},0.5,1.0

    # Layouts cycled by Super+Tab. Edit mangoCycleLayouts in this Nix module.
    circle_layout=${mangoCycleLayoutConfig}

    # Zero gaps for every Mango layout, including overview.
    smartgaps=0
    overviewgappi=0
    overviewgappo=0
    gappih=0
    gappiv=0
    gappoh=0
    gappov=0

    # Misc
    no_border_when_single=0
    focus_on_activate=1
    idleinhibit_ignore_visible=0
    sloppyfocus=1
    warpcursor=1
    focus_cross_monitor=0
    focus_cross_tag=0
    exchange_cross_monitor=0
    scratchpad_cross_monitor=1
    enable_floating_snap=0
    snap_distance=30
    cursor_size=24
    drag_tile_to_tile=1

    # Keyboard and pointer
    repeat_rate=25
    repeat_delay=600
    numlockon=0
    xkb_rules_layout=us
    disable_trackpad=0
    tap_to_click=1
    tap_and_drag=1
    drag_lock=1
    trackpad_natural_scrolling=0
    disable_while_typing=1
    mouse_natural_scrolling=0

    # Appearance
    scratchpad_width_ratio=0.8
    scratchpad_height_ratio=0.9
    borderpx=2
    rootcolor=0x222436ff
    bordercolor=0x00000000
    focuscolor=0x7aa2f7ee
    maximizescreencolor=0x89aa61ff
    urgentcolor=0xff757fff
    scratchpadcolor=0x3d59a1ff
    globalcolor=0xbb9af7ee
    overlaycolor=0x14a57cff

    # Monitor layout mirrors homeManager/modules/hyprland/monitors.nix.
    # Mango monitor rule key:value format; layout comes from the tagrules below.
    # VRR remains intentionally disabled.
    monitorrule=name:DP-2,scale:1,x:0,y:0,width:3440,height:1440,refresh:143.975,vrr:0
    monitorrule=name:eDP-1,scale:1.333333,x:3440,y:0,width:2560,height:1600,refresh:165.002

    # Mango no longer runs ~/.config/mango/autostart.sh by convention;
    # exec-once replaces it (starts quickshell + user services and desktop apps).
    exec-once=${lib.getExe mangoSessionStart}
    exec-once=${systemdRun} --user --scope --quiet --collect -- ${vesktop}
    exec-once=${systemdRun} --user --scope --quiet --collect -- ${spotify}
    exec-once=${lib.getExe mangoHerdr} preload

    # Closing disables the laptop panel; opening reenables it. A user service
    # also watches the ACPI lid state because Mango switch events can be
    # unreliable on this host.
    switchbind=fold,spawn,${lib.getExe mangoApplyLidState} closed
    switchbind=unfold,spawn,${lib.getExe mangoApplyLidState} open

    # Tags use Mango's scroller layout to approximate the current Hyprland scrolling layout.
    tagrule=id:1,layout_name:scroller
    tagrule=id:2,layout_name:scroller
    tagrule=id:3,layout_name:scroller
    tagrule=id:4,layout_name:scroller
    tagrule=id:5,layout_name:scroller
    tagrule=id:6,layout_name:scroller
    tagrule=id:7,layout_name:scroller
    tagrule=id:8,layout_name:scroller
    tagrule=id:9,layout_name:scroller
    tagrule=id:10,layout_name:scroller
    tagrule=id:11,layout_name:scroller

    # Quickshell command palette: keep Super+A like Hyprland, but let Mango center it as a floating window.
    windowrule=title:Command Palette,isfloating:1,isnoborder:1,isoverlay:1,noswallow:1,width:720,height:560
    windowrule=appid:vesktop,tags:9,istagsilent:1
    windowrule=appid:spotify,tags:10,istagsilent:1
    windowrule=appid:com.yvesd.herdr,tags:11,istagsilent:1

    # Core bindings
    bind=SUPER,r,reload_config
    bind=SUPER,comma,spawn,${qs} ipc call hints toggle
    bind=SUPER,g,spawn,govee-toggle
    bind=SUPER+SHIFT,g,spawn,${qs} ipc call lights toggle
    bind=SUPER,t,spawn,${lib.getExe mangoHerdr} open
    bind=SUPER,q,killclient,
    bind=SUPER,e,spawn,ghostty -e yazi
    bind=SUPER,w,togglefloating,
    bind=SUPER,a,spawn,${qs} ipc call command-palette toggle

    # Browser and app bindings
    bind=SUPER,f,spawn,helium-scoped
    bind=SUPER,h,spawn_shell,helium-scoped --incognito; ${qs} ipc call hints visable 0
    bind=SUPER,y,spawn,helium-scoped --new-window https://www.youtube.com/feed/subscriptions
    bind=SUPER,u,spawn,helium-scoped --new-window https://slate.sheridancollege.ca/d2l/login
    bind=SUPER+SHIFT,d,spawn,linuxmis
    bind=SUPER,d,spawn,linuxmis stream yves desktop

    # Shell companion actions
    bind=SUPER,c,spawn,${qs} ipc call zellij-sessions toggle
    bind=SUPER,n,spawn,${qs} ipc call sidebar toggle
    bind=SUPER,l,spawn,session-lock
    bind=SUPER,p,spawn_shell,grim -t png -g "$(slurp -d)" - | wl-copy -t image/png

    # Scroller layout approximations
    bind=SUPER,Tab,switch_layout
    bind=SUPER+SHIFT,Tab,spawn,${lib.getExe mangoCycleAllLayouts}
    bind=SUPER,period,exchange_client,left
    bind=SUPER,slash,exchange_client,right

    # Navigation
    bind=SUPER,Left,focusdir,left
    bind=SUPER,Right,focusdir,right
    bind=SUPER,Up,focusdir,up
    bind=SUPER,Down,focusdir,down
    bind=SUPER+ALT,Left,focusdir,left
    bind=SUPER+ALT,Right,focusdir,right
    bind=SUPER+ALT,Up,focusdir,up
    bind=SUPER+ALT,Down,focusdir,down

    # Resize
    bind=SUPER+SHIFT,Right,resizewin,+30,+0
    bind=SUPER+SHIFT,Left,resizewin,-30,+0
    bind=SUPER+SHIFT,Up,resizewin,+0,-30
    bind=SUPER+SHIFT,Down,resizewin,+0,+30

    # Tags mapped from Hyprland workspaces
    bind=SUPER,1,view,1,0
    bind=SUPER,2,view,2,0
    bind=SUPER,3,view,3,0
    bind=SUPER,4,view,4,0
    bind=SUPER,5,view,5,0
    bind=SUPER,6,view,6,0
    bind=SUPER,7,view,7,0
    bind=SUPER,8,view,8,0
    bind=SUPER,9,view,9,0
    bind=SUPER,0,view,10,0

    bind=SUPER+SHIFT,1,tag,1,0
    bind=SUPER+SHIFT,2,tag,2,0
    bind=SUPER+SHIFT,3,tag,3,0
    bind=SUPER+SHIFT,4,tag,4,0
    bind=SUPER+SHIFT,5,tag,5,0
    bind=SUPER+SHIFT,6,tag,6,0
    bind=SUPER+SHIFT,7,tag,7,0
    bind=SUPER+SHIFT,8,tag,8,0
    bind=SUPER+SHIFT,9,tag,9,0
    bind=SUPER+SHIFT,0,tag,10,0

    # Mouse bindings
    mousebind=SUPER,btn_left,moveresize,curmove
    mousebind=SUPER,btn_right,moveresize,curresize

    # Layer rules
    layerrule=animation_type_open:zoom,layer_name:rofi
    layerrule=animation_type_close:zoom,layer_name:rofi
  '';
in
  lib.mkIf (desktopWindowManager == "mango") {
    assertions = [
      {
        assertion = mangoCycleLayouts != [];
        message = "Mango cycle layouts must contain at least one layout.";
      }
      {
        assertion = unsupportedMangoCycleLayouts == [];
        message = "Mango cycle layouts contain unsupported layout names: ${lib.concatStringsSep ", " unsupportedMangoCycleLayouts}. Supported layouts: ${lib.concatStringsSep ", " mangoSupportedLayouts}.";
      }
    ];

    xdg.configFile."mango/config.conf".text = mangoConfig;

    home.packages = [
      mangoApplyLidState
      mangoCycleAllLayouts
      mangoHerdr
      mangoLidSwitchWatch
      mangoRestoreMonitors
      mangoSessionStart
    ];

    systemd.user.targets.mango-session = {
      Unit = {
        Description = "Mango compositor session";
        Documentation = ["man:systemd.special(7)"];
        BindsTo = ["graphical-session.target"];
        Wants = ["graphical-session-pre.target"];
        After = ["graphical-session-pre.target"];
      };
    };

    systemd.user.services.mango-lid-switch = {
      Unit = {
        Description = "Mango lid switch monitor handler";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        ExecStart = lib.getExe mangoLidSwitchWatch;
        # on-failure: the watcher exits 0 when no ACPI lid file exists; "always"
        # would crash-loop it into the start limit on such hosts.
        Restart = "on-failure";
        RestartSec = 2;
        Environment = [
          "XDG_CURRENT_DESKTOP=mango"
          "XDG_SESSION_DESKTOP=mango"
          "XDG_SESSION_TYPE=wayland"
        ];
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  }
