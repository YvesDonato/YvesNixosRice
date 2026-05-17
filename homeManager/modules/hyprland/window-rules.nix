''
  -- Window rules
  hl.window_rule({ name = "spotify-workspace", match = { class = "spotify" }, workspace = "10" })
  hl.window_rule({ name = "discord-workspace", match = { class = "discord" }, workspace = "9" })
  hl.window_rule({ name = "chatgpt-scratchpad", match = { class = "zen-beta", title = "^ChatGPT.*" }, float = true, size = "1200 900", center = true, workspace = "special:chatgpt" })
  hl.window_rule({ name = "floating-border", match = { float = true }, border_size = 2 })
  hl.window_rule({ name = "floating-opacity", match = { float = true }, opacity = "0.8" })
''
