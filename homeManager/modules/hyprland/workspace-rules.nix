''
  -- Workspace rules
  hl.workspace_rule({ workspace = "w[t1]", gaps_out = 0, gaps_in = 0 })
  hl.workspace_rule({ workspace = "w[tg1]", gaps_out = 0, gaps_in = 0 })
  hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

  hl.window_rule({ name = "no-rounding-tiled-workspace", match = { float = false, workspace = "w[t1]" }, rounding = 0 })
  hl.window_rule({ name = "no-rounding-group-workspace", match = { float = false, workspace = "w[tg1]" }, rounding = 0 })
  hl.window_rule({ name = "no-rounding-fullscreen-workspace", match = { float = false, workspace = "f[1]" }, rounding = 0 })
''
