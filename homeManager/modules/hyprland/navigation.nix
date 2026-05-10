''
  -- Navigation
  hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
  hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
  hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
  hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
  hl.bind(mainMod .. " + ALT + left", hl.dsp.focus({ direction = "left" }))
  hl.bind(mainMod .. " + ALT + right", hl.dsp.focus({ direction = "right" }))
  hl.bind(mainMod .. " + ALT + up", hl.dsp.focus({ direction = "up" }))
  hl.bind(mainMod .. " + ALT + down", hl.dsp.focus({ direction = "down" }))

  for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
  end

  hl.config({
    binds = {
      drag_threshold = 10,
    },
  })

  hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
  hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

  hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
  hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
  hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
  hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })
''
