{ config, pkgs, inputs, ... }:

{
  home.username = "yvesd";
  home.homeDirectory = "/home/yvesd";

  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = [
  
  ];

  home.file = {
  
  };
  
  home.sessionVariables = {
  
  };
  
  # Program Settings
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      clean = " sudo nix-env --delete-generations old; sudo nix-store --gc; sudo nix-collect-garbage -d; sudo nixos-rebuild boot";
    };
    
    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";
  };
  
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
  
  programs.starship = {
    enable = true;
    settings = {
      
    };
  };
  
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [
    ];
    extraConfig = ''
      monitor=eDP-1,2560x1600@165,0x0,1.5
      monitor=DP-2,3440x1440@175,1707x0,1
      exec-once = waybar & swaync & hypridle
      exec-once = bash ~/.config/hypr/start.sh
      env = XCURSOR_SIZE,24
      input {
        kb_layout = us
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
        gaps_in = 3
        gaps_out = 5
        border_size = 4
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)

        layout = dwindle
      }
      
      decoration {

        rounding = 5
    
        blur {
          enabled = true
          size = 3
          passes = 1
        }

        drop_shadow = true
        shadow_range = 4
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)
      }

      animations {
        enabled = true

        bezier = myBezier, 0.05, 0.9, 0.1, 1.05

        animation = windows, 1, 2, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 2, default
        animation = workspaces, 1, 2, default
      }

    dwindle {
      pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = yes # you probably want this
    }

    master {
      new_is_master = true
    }

    gestures {
      workspace_swipe = off
    }

    misc {
      force_default_wallpaper = -1 # Set to 0 to disable the anime mascot wallpapers
    }
    # See https://wiki.hyprland.org/Configuring/Keywords/ for more
    $mainMod = SUPER

    # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
    bind = $mainMod, T, exec, kitty
    bind = $mainMod SHIFT, T, exec, kitty zellij
    bind = $mainMod, Q, killactive,
    bind = $mainMod, E, exec, nautilus
    bind = $mainMod, W, togglefloating,
    bind = $mainMod, G, exec, gitg
    bind = $mainMod, A, exec, rofi -show drun -show-icons

    # Browser stuff
    bind = $mainMod, F, exec, firefox
    bind = $mainMod, H, exec, firefox --private-window # Private Window
    bind = $mainMod, Y, exec, firefox --new-window https://www.youtube.com/feed/subscriptions
    bind = $mainMod, U, exec, firefox --new-window https://slate.sheridancollege.ca/d2l/login
    bind = $mainMod, N, exec, 
    bind = $mainMod, O, exec, 

    bind = $mainMod, D, exec,
    bind = $mainMod, M, exec, 
    bind = $mainMod, B, exec, 
    bind = $mainMod, C, exec, firefox --new-window https://calendar.notion.so/
    bind = $mainMod, L, exec, hyprlock
    bind = $mainMod, P, exec, grim -g "$(slurp -d)" - | wl-copy
    bind = $mainMod, O, exec, obsidian

    windowrulev2 = workspace 10,DP-2, title:^(Blanket)$
    windowrulev2 = workspace 10,DP-2 title:^(Spotify Premium)$
    windowrulev2 = workspace 9,DP-2 class:^(discord)$
    
    # Move focus with mainMod + arrow keys
    bind = $mainMod, left, movefocus, l
    bind = $mainMod, right, movefocus, r
    bind = $mainMod, up, movefocus, u
    bind = $mainMod, down, movefocus, d

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

    # Scroll through existing workspaces with mainMod + scroll
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1

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

  programs.home-manager.enable = true;
}
