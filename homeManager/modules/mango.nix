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
  teams = lib.getExe pkgs-unstable.teams-for-linux;
  spotify = lib.getExe pkgs-unstable.spotify;
  chatgpt = lib.getExe (pkgs-unstable.callPackage ../../packages/chatgpt-desktop.nix {});
  morgen = lib.getExe pkgs-unstable.morgen;
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
  # cycle-all script maps through it. Keep in sync with layouts[] in
  # src/layout/arrange.c (src/layout/layout.h before 0.18) when bumping mango.
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

  # 0.18's reload_config re-enables disabled outputs, so docked with the lid
  # shut Super+R would wake the laptop panel; turn it back off afterwards.
  mangoReload = pkgs.writeShellApplication {
    name = "mango-reload";
    runtimeInputs = [
      mangowcPatched
      pkgs.gnugrep
      pkgs.gnused
      pkgs.jq
      pkgs.libnotify
    ];
    text = ''
      # 0.18 segfaults if a reload changes tag_num (tags it never set up get
      # queried by IPC), so that change needs a fresh login instead.
      new="$(sed -n 's/^tag_num=//p' "$HOME/.config/mango/config.conf")"
      cur="$(mmsg get all-monitors | jq -r 'first(.monitors[]?.tag_num) // empty')"
      if [ -n "$new" ] && [ -n "$cur" ] && [ "$new" != "$cur" ]; then
        notify-send -u critical -a Mango "Not reloading" "tag_num changed ($cur -> $new); log out and back in instead."
        exit 1
      fi
      mmsg dispatch reload_config
      if grep -qs closed /proc/acpi/button/lid/*/state; then
        ${lib.getExe mangoApplyLidState} closed
      fi
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

  # Google Messages runs as a Helium app window (see helium-scoped.nix);
  # Chromium names its Wayland app_id after the URL.
  messages = "chrome-messages.google.com__web-Default";

  # Herdr (Super+T), Discord + Google Messages + both Teams (Super+S), Morgen
  # (Super+C) and the ChatGPT/Codex app (Super+X) share mango's single special
  # workspace (tag 0, which dims everything behind it). Each command moves its
  # own group onto tag 0 and parks the others on their old tags (overlayPark),
  # so only one group shows at a time.
  overlayLaunch = {
    morgen = morgen;
    chatgpt = chatgpt;
    "com.yvesd.herdr" = "${ghostty} --class=com.yvesd.herdr -e ${herdr}";
    vesktop = vesktop;
    # Its own Helium profile: an --app launch that starts Helium skips (and
    # then overwrites) the main profile's session restore.
    ${messages} = ''helium-scoped --user-data-dir="$HOME/.config/helium-messages" --app=https://messages.google.com/web'';
    # Each Teams account needs its own profile dir; stereoLOGIC keeps the
    # original teams-for-linux profile.
    teams-sheridan = ''${teams} --class=teams-sheridan --user-data-dir="$HOME/.config/teams-sheridan" --appTitle="Teams (Sheridan)"'';
    teams-stereologic = ''${teams} --class=teams-stereologic --user-data-dir="$HOME/.config/teams-for-linux" --appTitle="Teams (stereoLOGIC)"'';
  };
  # Where each window sits on whichever monitor shows it, in 1/10000ths of that
  # monitor: x y width height. The comms thirds share their edges exactly; both
  # Teams accounts share the right one as tabs.
  overlayGeom = {
    "com.yvesd.herdr" = [1000 500 8000 9000];
    vesktop = [0 500 3333 9000];
    ${messages} = [3333 500 3334 9000];
    teams-sheridan = [6667 500 3333 9000];
    teams-stereologic = [6667 500 3333 9000];
    morgen = [1000 500 8000 9000];
    chatgpt = [1000 500 8000 9000];
  };
  # Where each window waits while another group has the special workspace
  # (the window rules also start them there).
  overlayPark = {
    "com.yvesd.herdr" = 11;
    vesktop = 13;
    ${messages} = 13;
    teams-sheridan = 13;
    teams-stereologic = 13;
    morgen = 12;
    chatgpt = 13;
  };

  mkOverlay = {
    name,
    apps,
    # Apps whose windows share one slot as a mango window group (tabs); they
    # need the same overlayGeom and overlayPark.
    tabs ? [],
  }:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.coreutils
        pkgs.jq
        pkgs.util-linux
        mangowcPatched
      ];
      text = ''
        # open shows this group and focuses it, toggle hides it again when it
        # is already showing, preload only starts any missing apps.
        mode="''${1:-open}"
        case "$mode" in
          open | toggle | preload) ;;
          *)
            printf 'usage: %s open|toggle|preload\n' "$0" >&2
            exit 2
            ;;
        esac

        mine='${builtins.toJSON apps}'
        tabs='${builtins.toJSON tabs}'
        park='${builtins.toJSON overlayPark}'

        launch() {
          local cmd
          case "$1" in
        ${lib.concatMapStrings (app: "    ${app}) cmd=(${overlayLaunch.${app}}) ;;\n") apps}    esac
          ${systemdRun} --user --scope --quiet --collect -- "''${cmd[@]}" 9>&- </dev/null >/dev/null 2>&1 &
        }

        # A group's clients as a JSON array ([] if mango isn't answering), each
        # with .slot: its app, or the first tab app for all the tab apps.
        group() {
          mmsg get all-clients | jq -c --argjson apps "$1" --argjson tabs "$tabs" '[.clients[]? | select(.appid as $a | $apps | index($a))
            | .slot = (if (.appid as $a | $tabs | index($a)) != null then $tabs[0] else .appid end)]' || echo '[]'
        }

        # Apps that have a window. A window group lists only the tab it shows,
        # so a grouped tab app stands in for all of them.
        present() {
          jq -c --argjson tabs "$tabs" '[.[].appid] + (if any(.[]; .is_group and .slot == $tabs[0]) then $tabs else [] end) | unique' <<<"$clients"
        }

        lock_file="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/mango-overlay.lock"
        exec 9>"$lock_file"
        flock 9

        clients="$(group "$mine")"
        have="$(present)"
        while read -r app; do
          jq -e --arg app "$app" 'any(.[]; . == $app)' <<<"$have" >/dev/null || launch "$app"
        done < <(jq -r '.[]' <<<"$mine")
        [ "$mode" = "preload" ] && exit 0

        # Give freshly launched apps up to 30s to map.
        for _ in {1..300}; do
          clients="$(group "$mine")"
          [ "$(present | jq length)" -ge "$(jq length <<<"$mine")" ] && break
          sleep 0.1
        done
        first="$(jq -r 'first(.[].id) // empty' <<<"$clients")"
        [ -n "$first" ] || exit 1

        # Everything happens on the focused monitor (where the key was pressed).
        read -r mon mx my mw mh < <(mmsg get all-monitors | jq -r 'first(.monitors[]? | select(.active)) | "\(.name) \(.x) \(.y) \(.width) \(.height)"')
        # ponytail: mmsg only reports the full monitor; the Quickshell bar
        # reserves 42px on the right of every screen (Bar.qml implicitWidth).
        # Read it from mango if a bar ever moves or changes size.
        mw=$((mw - 42))
        on_tag0='select((.tags // []) | index(0) != null)'

        # Showing here already: hide it. Showing on another monitor: hide it
        # there, then fall through and bring it here.
        while read -r id where; do
          if [ "$where" = "$mon" ]; then
            [ "$mode" = "toggle" ] && exec mmsg dispatch toggle_special_tag "client,$id"
          else
            mmsg dispatch toggle_special_tag "client,$id" >/dev/null
          fi
        done < <(jq -r "[.[] | $on_tag0 | select(.is_visible)] | unique_by(.monitor) | .[] | \"\(.id) \(.monitor)\"" <<<"$clients")

        # Park the other groups if they are on this monitor's special workspace.
        mmsg get all-clients | jq -r --arg m "$mon" --argjson park "$park" --argjson mine "$mine" '
          .clients[]? | .appid as $a
          | select(.monitor == $m and ((.tags // []) | index(0) != null))
          | select($park[$a] != null and ($mine | index($a)) == null)
          | "\(.id) \($park[$a])"' | while read -r id tag; do
          mmsg dispatch "tagsilent,$tag" "client,$id" >/dev/null
        done

        # An app's slot on this monitor in pixels: x0..x1 by y0..y1.
        slot() {
          # Fractions of the monitor in 1/10000ths: x y width height.
          case "$1" in
        ${lib.concatMapStrings (app: "    ${app}) g=(${toString overlayGeom.${app}}) ;;\n") apps}    esac
          x0=$(((mw * g[0] + 5000) / 10000)) x1=$(((mw * (g[0] + g[2]) + 5000) / 10000))
          y0=$(((mh * g[1] + 5000) / 10000)) y1=$(((mh * (g[1] + g[3]) + 5000) / 10000))
        }

        # place ID MONITOR ON_TAG0 FLOATING: float the window at x0..x1 by
        # y0..y1 on this monitor's special workspace.
        place() {
          # tag_special_silent toggles, so only for windows not on tag 0 yet.
          [ "$3" = "true" ] || mmsg dispatch tag_special_silent "client,$1" >/dev/null
          # tagmon also switches that monitor's view to the window's tag (0).
          [ "$2" = "$mon" ] || mmsg dispatch "tagmon,$mon,1" "client,$1" >/dev/null
          # Windows mapped before their float rule existed are still tiled.
          [ "$4" = "true" ] || mmsg dispatch togglefloating "client,$1" >/dev/null
          mmsg dispatch "resizewin,$((x1 - x0)),$((y1 - y0))" "client,$1" >/dev/null
          mmsg dispatch "movewin,$((mx + x0)),$((my + y0))" "client,$1" >/dev/null
        }
        state='"\(.id) \(.monitor) \((.tags // []) | index(0) != null) \(.is_floating)"'

        # Join the tab apps' main windows into one mango window group. mango
        # drops a group as soon as one of its windows closes, so redo this
        # whenever they are listed separately. A window left over from a
        # broken group still counts as its shown tab, and joining FROM it
        # leaves both windows showing (client_focus_group_member), so the
        # joiner is one this script never grouped before (ids are unique per
        # mango run), else the newer one. The joiner takes the target's
        # place: the target goes in the tab slot and the joiner centres on
        # its left edge, so the target is the only window to its right.
        sig="''${MANGO_INSTANCE_SIGNATURE:-mango}"
        joined_file="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/mango-overlay-joined-''${sig##*/}"
        joined="$(jq -sc . "$joined_file" 2>/dev/null)" || joined='[]'
        # Minimized windows can't be joined (or seen as showing).
        pair="$(jq -c --argjson tabs "$tabs" --argjson joined "$joined" '[.[] | select(.appid as $a | $tabs | index($a) != null) | select(.is_minimized | not)]
          | if any(.[]; .is_group) then [] else group_by(.appid) | map(min_by(.id))
            | sort_by([(.id as $i | $joined | index($i)) == null, .id]) end' <<<"$clients")"
        if [ "$(jq length <<<"$pair")" -ge 2 ]; then
          slot "$(jq -r '.[0]' <<<"$tabs")"
          while read -r id where on0 floating; do
            place "$id" "$where" "$on0" "$floating"
            w=$((x1 - x0)) x0=$((x0 - (x1 - x0) / 2))
            x1=$((x0 + w))
          done < <(jq -r ".[0:2][] | $state" <<<"$pair")
          target="$(jq '.[0].id' <<<"$pair")" joiner="$(jq '.[1].id' <<<"$pair")"
          # groupjoin only finds windows on a view that is showing.
          mmsg get all-clients | jq -e --argjson id "$target" 'any(.clients[]?; .id == $id and .is_visible)' >/dev/null ||
            mmsg dispatch toggle_special_tag "client,$target" >/dev/null
          mmsg dispatch groupjoin,right "client,$joiner" >/dev/null
          clients="$(group "$mine")"
          if ! jq -e --argjson id "$joiner" 'any(.[]; .id == $id and .is_group)' <<<"$clients" >/dev/null; then
            : # Nothing joined (e.g. the target is minimized); both stay in the slot.
          elif jq -e --argjson id "$target" 'any(.[]; .id == $id)' <<<"$clients" >/dev/null; then
            # It grouped with some other window: undo that.
            mmsg dispatch groupleave "client,$joiner" >/dev/null
            clients="$(group "$mine")"
          else
            printf '%s\n' "$target" "$joiner" >>"$joined_file"
          fi
          first="$(jq -r 'first(.[].id) // empty' <<<"$clients")"
        fi

        # Slots go left to right in $mine order, skipping apps without a
        # window. One that comes out wider than its slot (vesktop won't go
        # below 944px) pushes the rest right, and they split what's left of
        # the row, so a laptop screen doesn't overlap them while a wide
        # monitor keeps the exact slots.
        end=$(((mw * ${toString (lib.foldl lib.max 0 (map (app: let g = overlayGeom.${app}; in builtins.elemAt g 0 + builtins.elemAt g 2) apps))} + 5000) / 10000))
        slots="$(jq -r --argjson mine "$mine" '. as $c | $mine[] | select(. as $s | any($c[]; .slot == $s))' <<<"$clients")"
        left=$(wc -l <<<"$slots") cursor=0
        while read -r app; do
          slot "$app"
          [ "$cursor" -le "$x0" ] || x0=$cursor x1=$((cursor + (end - cursor) / left))
          right=$x1
          while read -r id where on0 floating; do
            place "$id" "$where" "$on0" "$floating"
            # mango clamps to the app's minimum size straight away.
            w="$(mmsg get all-clients | jq --argjson id "$id" 'first(.clients[]? | select(.id == $id) | .width) // 0')"
            [ "$((x0 + w))" -le "$right" ] || right=$((x0 + w))
          done < <(jq -r --arg app "$app" ".[] | select(.slot == \$app) | $state" <<<"$clients")
          cursor=$right left=$((left - 1))
        done <<<"$slots"

        # tagmon may already have switched this monitor to tag 0.
        jq -e 'any(.[]; .is_visible)' <<<"$(group "$mine")" >/dev/null ||
          mmsg dispatch toggle_special_tag "client,$first" >/dev/null
        exec mmsg dispatch focusid "client,$first"
      '';
    };

  mangoHerdr = mkOverlay {
    name = "mango-herdr";
    apps = ["com.yvesd.herdr"];
  };

  mangoComms = mkOverlay {
    name = "mango-comms";
    apps = ["vesktop" messages "teams-sheridan" "teams-stereologic"];
    tabs = ["teams-sheridan" "teams-stereologic"];
  };

  mangoMorgen = mkOverlay {
    name = "mango-morgen";
    apps = ["morgen"];
  };

  mangoCodex = mkOverlay {
    name = "mango-codex";
    apps = ["chatgpt"];
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
      for variable in DISPLAY QT_QPA_PLATFORM WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE MANGO_INSTANCE_SIGNATURE LINUXMIS_MANGO_SPLIT; do
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
    smart_gaps=0
    overview_gap_inner=0
    overview_gap_outer=0
    gap_inner_horizontal=0
    gap_inner_vertical=0
    gap_outer_horizontal=0
    gap_outer_vertical=0

    # Misc
    no_border_when_single=0
    focus_on_activate=1
    idle_inhibit_ignore_visible=0
    sloppy_focus=1
    warp_cursor=1
    focus_cross_monitor=0
    focus_cross_tag=0
    exchange_cross_monitor=0
    scratchpad_cross_monitor=1
    enable_floating_snap=0
    snap_distance=30
    cursor_size=24
    drag_tile_to_tile=1

    # New in 0.18, turned off to keep 0.15 behaviour: auto reload would also
    # wake the lid-closed panel (see mango-reload), a 10px resize strip would
    # eat clicks at window edges, and monocle/deck would grow tab bars.
    auto_reload_config=0
    enable_border_resize=0
    monocle_tab_mode=0
    deck_tab_mode=0
    focus_direction_only_zone_overlap=0

    # Keyboard and pointer
    repeat_rate=25
    repeat_delay=600
    numlock_on=0
    xkb_rules_layout=us
    disable_trackpad=0
    tap_to_click=1
    tap_and_drag=1
    drag_lock=1
    trackpad_natural_scrolling=0
    trackpad_disable_while_typing=1
    mouse_natural_scrolling=0

    # Appearance
    scratchpad_width_ratio=0.8
    scratchpad_height_ratio=0.9
    border_px=2
    root_color=0x222436ff
    border_color=0x00000000
    focus_color=0x7aa2f7ee
    maximized_screen_color=0x89aa61ff
    urgent_color=0xff757fff
    scratchpad_color=0x3d59a1ff
    global_color=0xbb9af7ee
    overlay_color=0x14a57cff

    # Monitor layout mirrors homeManager/modules/hyprland/monitors.nix.
    # Mango monitor rule key:value format; layout comes from the tag_rules below.
    # VRR remains intentionally disabled.
    monitor_rule=name:DP-2,scale:1,x:0,y:0,width:3440,height:1440,refresh:143.975,vrr:0
    monitor_rule=name:eDP-1,scale:1.333333,x:3440,y:0,width:2560,height:1600,refresh:165.002

    # Mango no longer runs ~/.config/mango/autostart.sh by convention;
    # exec_once replaces it (starts quickshell + user services and desktop apps).
    exec_once=${lib.getExe mangoSessionStart}
    exec_once=${lib.getExe mangoComms} preload
    exec_once=${systemdRun} --user --scope --quiet --collect -- ${spotify}
    exec_once=${lib.getExe mangoCodex} preload
    exec_once=${lib.getExe mangoHerdr} preload
    exec_once=${lib.getExe mangoMorgen} preload

    # Closing disables the laptop panel; opening reenables it. A user service
    # also watches the ACPI lid state because Mango switch events can be
    # unreliable on this host.
    switchbind=fold,spawn,${lib.getExe mangoApplyLidState} closed
    switchbind=unfold,spawn,${lib.getExe mangoApplyLidState} open

    # 13 tags: 10 holds Spotify; 11-13 only park the special-workspace groups
    # (herdr, Morgen, the Codex app + Discord/Messages/Teams), so 1-9 stay regular.
    # Mango 0.18 supports this natively via tag_num (1-31).
    tag_num=13

    # Tags use Mango's scroller layout to approximate the current Hyprland scrolling layout.
    tag_rule=id:1,layout_name:scroller
    tag_rule=id:2,layout_name:scroller
    tag_rule=id:3,layout_name:scroller
    tag_rule=id:4,layout_name:scroller
    tag_rule=id:5,layout_name:scroller
    tag_rule=id:6,layout_name:scroller
    tag_rule=id:7,layout_name:scroller
    tag_rule=id:8,layout_name:scroller
    tag_rule=id:9,layout_name:scroller
    tag_rule=id:10,layout_name:scroller
    tag_rule=id:11,layout_name:scroller
    tag_rule=id:12,layout_name:scroller

    # Quickshell command palette: keep Super+A like Hyprland, but let Mango center it as a floating window.
    window_rule=title:Command Palette,is_floating:1,no_border:1,is_overlay:1,no_swallow:1,width:720,height:560
    # The ChatGPT/Codex app floats like herdr and parks on tag 13 until Super+X;
    # 0.8 opacity matches ghostty's background-opacity (mango fades the whole window).
    window_rule=app_id:^chatgpt$,tags:13,is_tag_silent:1,is_floating:1,width:0.8,height:0.9,focused_opacity:0.8,unfocused_opacity:0.8
    # Discord | Google Messages | Teams (Sheridan and stereoLOGIC as tabs of
    # one window group): floating thirds with touching edges, parked on tag 13
    # until Super+S (mango-comms) moves them onto the special workspace and
    # groups the Teams windows. Click a tab in the bar above Teams to switch.
    window_rule=app_id:^vesktop$,tags:13,is_tag_silent:1,is_floating:1,width:0.3334,height:0.9,offset_x:-100
    window_rule=app_id:^${lib.escapeRegex messages}$,tags:13,is_tag_silent:1,is_floating:1,width:0.3334,height:0.9
    window_rule=app_id:^teams-sheridan$,tags:13,is_tag_silent:1,is_floating:1,width:0.3334,height:0.9
    window_rule=app_id:^teams-stereologic$,tags:13,is_tag_silent:1,is_floating:1,width:0.3334,height:0.9,offset_x:100
    window_rule=app_id:^com\.linuxmis\.linuxmis$,title:^Linuxmis Native Stream$,monitor:DP-2,is_floating:0,no_border:1,no_swallow:1,reserve_right:1
    window_rule=app_id:spotify,tags:10,is_tag_silent:1
    # Herdr floats on the special workspace (tag 0); Super+T (mango-herdr)
    # toggles it and parks it on tag 11 while Super+S shows the comms group.
    window_rule=app_id:com.yvesd.herdr,tags:0,is_tag_silent:1,is_floating:1,width:0.8,height:0.9
    # Morgen floats like herdr and parks on tag 12 until Super+C shows it.
    window_rule=app_id:^morgen$,tags:12,is_tag_silent:1,is_floating:1,width:0.8,height:0.9

    # Core bindings
    bind=SUPER,r,spawn,${lib.getExe mangoReload}
    bind=SUPER,comma,spawn,${qs} ipc call hints toggle
    bind=SUPER,g,spawn,govee-toggle
    bind=SUPER+SHIFT,g,spawn,${qs} ipc call lights toggle
    bind=SUPER,t,spawn,${lib.getExe mangoHerdr} toggle
    bind=SUPER,s,spawn,${lib.getExe mangoComms} toggle
    bind=SUPER,q,killclient,
    bind=SUPER,e,spawn,ghostty -e yazi
    bind=SUPER,w,togglefloating,
    bind=SUPER,a,spawn,${qs} ipc call command-palette toggle

    # Browser and app bindings
    bind=SUPER,c,spawn,${lib.getExe mangoMorgen} toggle
    bind=SUPER,x,spawn,${lib.getExe mangoCodex} toggle
    bind=SUPER,f,spawn,helium-scoped
    bind=SUPER,h,spawn_shell,helium-scoped --incognito; ${qs} ipc call hints visable 0
    bind=SUPER,y,spawn,helium-scoped --new-window https://www.youtube.com/feed/subscriptions
    bind=SUPER,u,spawn,helium-scoped --new-window https://slate.sheridancollege.ca/d2l/login
    bind=SUPER+SHIFT,d,spawn,linuxmis
    bind=SUPER,d,spawn,linuxmis stream yves desktop

    # Shell companion actions
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
    layer_rule=animation_type_open:zoom,layer_name:rofi
    layer_rule=animation_type_close:zoom,layer_name:rofi
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
      mangoComms
      mangoHerdr
      mangoCodex
      mangoMorgen
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
