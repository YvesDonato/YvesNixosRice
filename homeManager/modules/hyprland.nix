{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {

  imports = [
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs-unstable.hyprland;
    plugins = [
      pkgs-unstable.hyprlandPlugins.hy3
    ];
    extraConfig = ''
      monitor = , highres@highrr, auto, 1, vrr, 0
      monitor = eDP-1, highres@highrr, auto-left, 1.333333, vrr, 1
      #monitor = DP-2, highres@highrr, auto, 1, vrr, 0, bitdepth, 10

      # monitorv2 {
      #   output = eDP-1
      #   mode = highres@highrr
      #   position = auto
      #   scale = 1.333333
      #   vrr = 1
      # }
      
      monitorv2 {
        output = DP-2
        mode = highres@highrr
        position = auto
        scale = 1
        vrr = 0
        bitdepth = 10
        cm = auto
        # sdrbrightness = 1.2
        # sdrsaturation = 0.98
        # supports_wide_color = 1
        # supports_hdr = 1
        sdr_min_luminance = 0.005
        # sdr_max_luminance = 248
        # sdr_max_luminance = 60

        # min_luminance = 0.005
        # max_luminance = 1047
        # max_avg_luminance = 484
      }
      
      #, cm, hdr, sdrbrightness, 1.2, sdrsaturation, 0.98
      monitor = DP-3, highres@highrr, 1920x0, 1, vrr, 0
      bindl = , switch:on:Lid Switch, exec, hyprctl keyword monitor "eDP-1, disable"
      bindl = , switch:off:Lid Switch, exec, hyprctl keyword monitor "eDP-1, highres@highrr, auto-left, 1.333333, vrr, 1"
      exec-once = quickshell -d & hypridle
      exec-once = bash ~/.config/hypr/start.sh
      env = HYPRCURSOR_THEME,rose-pine-hyprcursor
      env = HYPRCURSOR_SIZE,24

      experimental {
        xx_color_management_v4 = true
      }

      render {
        cm_fs_passthrough = 0
        cm_auto_hdr = 1
      }

      plugin {
        hy3 {
          autotile {
            enable = true
            trigger_width = 848
          }
          tabs {
            text_font = Hack Nerd Font Mono
            text_height = 11
            height = 25
            col.active = rgba(3d85c640)
          }
        }
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
        snap {
          enabled = true
        }
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

      # master {
      #   orientation = center
      #   mfact = 0.34
      # }

      gestures {
        workspace_swipe = off
      }

      misc {
        force_default_wallpaper = 0 # Set to 0 to disable the anime mascot wallpapers
        vrr = 1
      }
      
      $mainMod = SUPER
      $browser = zen-beta
      $clear = qs ipc call hints visable 0
      bindlnot=,Super_L,exec, qs ipc call hints visable 1
      bindlnrt=$mainMod,Super_L,exec, qs ipc call hints visable 0

      bind = $mainMod, G, exec, bash /home/yvesd/Nixos/homeManager/modules/scripts/lights.bash

      # bindo = , Super_L, exec, qs ipc call hints visable 1
      # bindr = $mainMod , Super_L, exec, qs ipc call hints visable 0
      bind = $mainMod, T, exec, ghostty
      bind = $mainMod, Q, killactive

      bind = $mainMod, E, exec, ghostty -e yazi
      bind = $mainMod, W, togglefloating
      bind = $mainMod, G, exec, 
      bind = $mainMod, A, exec, /home/yvesd/Nixos/homeManager/modules/scripts/rofi/main-menu.sh
      # bind = $mainMod, S, exec, /home/yvesd/Nixos/Configuration/Configs/rofi/scripts/uni-search.sh;

      # Browser stuff
      bind = $mainMod, F, exec, $browser
      bind = $mainMod, H, exec, $browser --private-window; $clear # Private Window
      bind = $mainMod, Y, exec, $browser --new-window https://www.youtube.com/feed/subscriptions; 
      bind = $mainMod, U, exec, $browser --new-window https://slate.sheridancollege.ca/d2l/login; 
      bind = $mainMod, N, exec,

      bind = $mainMod SHIFT, D, exec, moonlight
      bind = $mainMod, D, exec, moonlight stream yves desktop
      bind = $mainMod CTRL, V, hy3:makegroup, v, ephemeral
      bind = $mainMod CTRL, T, hy3:makegroup, tab, ephemeral

      # bind = $mainMod SHIFT, M, hy3:makegroup, tab, force_ephemeral

      bind = $mainMod, B, togglespecialworkspace

      bind = $mainMod, C, exec,
      bind = $mainMod, L, exec, hyprlock
      bind = $mainMod, P, exec, grim -g "$(slurp -d)" - | wl-copy

      windowrulev2 = workspace 10, DP-2 class:^(spotify)$
      windowrulev2 = workspace 9, DP-2 class:^(discord)$
      windowrulev2 = bordersize 2, floating:1
      windowrulev2 = opacity 0.8, floating:1

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

      binds {
          drag_threshold = 10
      }
      
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
}
