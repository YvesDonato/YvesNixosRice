''
  -- Appearance
  hl.config({
    general = {
      gaps_out = 0,
      gaps_in = 0,
      border_size = 0,
      col = {
        active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
        inactive_border = "rgba(595959aa)",
      },
      layout = "scrolling",
      snap = {
        enabled = true,
      },
    },
    decoration = {
      rounding = 0,
      blur = {
        enabled = true,
        size = 3,
        passes = 1,
      },
    },
    animations = {
      enabled = false,
    },
    scrolling = {
      fullscreen_on_one_column = true,
      column_width = 1 / 3,
      focus_fit_method = 1,
      follow_focus = true,
      explicit_column_widths = "0.3333333333, 0.5, 1.0",
      follow_min_visible = 1.0,
      wrap_focus = true,
      wrap_swapcol = true,
      direction = "right",
    },
  })
''
