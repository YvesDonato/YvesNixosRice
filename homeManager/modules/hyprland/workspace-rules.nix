''

  workspace = w[t1], gapsout:0, gapsin:0
  workspace = w[tg1], gapsout:0, gapsin:0
  workspace = f[1], gapsout:0, gapsin:0
  windowrulev2 = bordersize 0, floating:0, onworkspace:w[t1]
  windowrulev2 = rounding 0, floating:0, onworkspace:w[t1]
  windowrulev2 = bordersize 0, floating:0, onworkspace:w[tg1]
  windowrulev2 = rounding 0, floating:0, onworkspace:w[tg1]
  windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
  windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

  # dwindle {
  #   pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
  #   preserve_split = yes # you probably want this
  # }

  # master {
  #   orientation = center
  #   mfact = 0.34
  # }
''
