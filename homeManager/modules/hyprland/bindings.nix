''
  -- Core bindings
  local mainMod = "SUPER"
  local browser = "zen-scoped"
  local chatgptScratchpad = "/home/yvesd/nixos/homeManager/modules/scripts/toggle-chatgpt-scratchpad.sh"
  local clearCommand = "qs ipc call hints visable 0"

  hl.bind("Super_L", hl.dsp.exec_cmd("qs ipc call hints visable 1"), { locked = true, non_consuming = true, long_press = true, transparent = true })
  hl.bind(mainMod .. " + Super_L", hl.dsp.exec_cmd(clearCommand), { locked = true, non_consuming = true, release = true, transparent = true })
  hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("qs ipc call hints toggle"))

  hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("bash /home/yvesd/nixos/homeManager/modules/scripts/lights.bash"))
  hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("qs ipc call lights toggle"))
  hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("ghostty -e herdr"))
  hl.bind(mainMod .. " + Q", hl.dsp.window.close())
  hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("ghostty -e yazi"))
  hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
  hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("qs ipc call command-palette toggle"))

  -- Browser stuff
  hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))
  hl.bind(mainMod .. " + H", hl.dsp.exec_cmd(browser .. " --private-window; " .. clearCommand))
  hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(browser .. " --new-window https://www.youtube.com/feed/subscriptions"))
  hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(browser .. " --new-window https://slate.sheridancollege.ca/d2l/login"))
  hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("ENABLE_HDR_WSI=1 linuxmis"))
  hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("ENABLE_HDR_WSI=1 linuxmis stream yves desktop"))

  hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(chatgptScratchpad))
  hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("qs ipc call zellij-sessions toggle"))
  hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("qs ipc call lock locked true"))
  hl.bind(mainMod .. " + P", hl.dsp.exec_cmd([[grim -g "$(slurp -d)" - | wl-copy]]))

  -- Scroll window
  hl.bind(mainMod .. " + Tab", hl.dsp.layout("colresize +conf"))
  hl.bind(mainMod .. " + period", hl.dsp.layout("move -col"))
  hl.bind(mainMod .. " + slash", hl.dsp.layout("move +col"))
''
