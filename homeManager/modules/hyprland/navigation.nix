''

  # Move focus with mainMod + arrow keys
  bind = $mainMod, left, hy3:movefocus, l, visible
  bind = $mainMod, right, hy3:movefocus, r, visible
  bind = $mainMod, up, hy3:movefocus, u, visible
  bind = $mainMod, down, hy3:movefocus, d, visible
  bind = $mainMod ALT, left,  hy3:movefocus, l
  bind = $mainMod ALT, right, hy3:movefocus, r
  bind = $mainMod ALT, up,    hy3:movefocus, u
  bind = $mainMod ALT, down,  hy3:movefocus, d

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

''
