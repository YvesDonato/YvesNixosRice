''
  -- Monitors
  hl.monitor({ output = "", mode = "highres@highrr", position = "auto", scale = 1, vrr = 0 })
  hl.monitor({ output = "eDP-1", mode = "highres@highrr", position = "auto", scale = 1.333333, vrr = 1 })
  hl.monitor({ output = "HEADLESS-2", disabled = true })

  hl.monitor({
    output = "DP-2",
    mode = "3440x1440@143.97",
    position = "auto-left",
    scale = 1,
    vrr = 0,
    bitdepth = 10,
    cm = "auto",
    sdrbrightness = 0.95,
  })

  hl.monitor({ output = "desc:AOC 16T20 A6T2550Z00866", mode = "1920x1080@60", position = "auto-left", scale = 1 })
  hl.monitor({ output = "DP-3", mode = "highres@highrr", position = "1920x0", scale = 1, vrr = 0 })
  hl.bind(
    "switch:on:Lid Switch",
    hl.dsp.exec_cmd([[hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })']]),
    { locked = true }
  )
  hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl reload"), { locked = true })
''
