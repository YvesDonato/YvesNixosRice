''

  $mainMod = SUPER
  $browser = zen-beta
  $clear = qs ipc call hints visable 0
  bindlnot=,Super_L,exec, qs ipc call hints visable 1
  bindlnrt=$mainMod,Super_L,exec, qs ipc call hints visable 0
  bind = $mainMod, slash, exec, qs ipc call hints toggle

  bind = $mainMod, G, exec, bash /home/yvesd/nixos/homeManager/modules/scripts/lights.bash

  # bindo = , Super_L, exec, qs ipc call hints visable 1
  # bindr = $mainMod , Super_L, exec, qs ipc call hints visable 0
  bind = $mainMod, T, exec, ghostty
  bind = $mainMod, Q, killactive

  bind = $mainMod, E, exec, ghostty -e yazi
  bind = $mainMod, W, togglefloating
  bind = $mainMod, A, exec, qs ipc call command-palette toggle
  bind = $mainMod, X, exec, qs ipc call codex-control toggle
  # bind = $mainMod, A, exec, rofi -show drun
  # bind = $mainMod, S, exec, /home/yvesd/nixos/Configuration/Configs/rofi/scripts/uni-search.sh;

  # Browser stuff
  bind = $mainMod, F, exec, $browser
  bind = $mainMod, H, exec, $browser --private-window; $clear # Private Window
  bind = $mainMod, Y, exec, $browser --new-window https://www.youtube.com/feed/subscriptions;
  bind = $mainMod, U, exec, $browser --new-window https://slate.sheridancollege.ca/d2l/login;
  bind = $mainMod SHIFT, D, exec, ENABLE_HDR_WSI=1 linuxmis
  bind = $mainMod, D, exec, ENABLE_HDR_WSI=1 linuxmis stream yves desktop
  bind = $mainMod CTRL, V, hy3:makegroup, v, ephemeral
  bind = $mainMod CTRL, T, hy3:makegroup, tab, ephemeral

  # bind = $mainMod SHIFT, M, hy3:makegroup, tab, force_ephemeral

  bind = $mainMod, B, togglespecialworkspace

  bind = $mainMod, C, exec, qs ipc call zellij-sessions toggle
  bind = $mainMod, L, exec, qs ipc call lock locked true
  bind = $mainMod, P, exec, grim -g "$(slurp -d)" - | wl-copy
''
