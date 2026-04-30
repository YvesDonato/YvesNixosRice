''
  monitor = , highres@highrr, auto, 1, vrr, 0
  monitor = eDP-1, highres@highrr, auto, 1.333333, vrr, 1
  #monitor = DP-2, highres@highrr, auto, 1, vrr, 0, bitdepth, 10
  monitor = HEADLESS-2, disable
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
    position = auto-left
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

  monitor = desc:AOC 16T20 A6T2550Z00866,1920x1080@60,auto-left,1

  #, cm, hdr, sdrbrightness, 1.2, sdrsaturation, 0.98
  monitor = DP-3, highres@highrr, 1920x0, 1, vrr, 0
  bindl = , switch:on:Lid Switch, exec, bash /home/yvesd/nixos/homeManager/modules/scripts/hypr-lid-handler.bash closed
  bindl = , switch:off:Lid Switch, exec, bash /home/yvesd/nixos/homeManager/modules/scripts/hypr-lid-handler.bash open
''
