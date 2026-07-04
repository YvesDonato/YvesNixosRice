{...}: {
  # herdr keybindings — make the prefix-based multiplexer feel like zellij.
  #
  # herdr is prefix-based (Ctrl+b then a key); zellij is modal. A literal mirror
  # isn't possible (herdr has no general pane/tab/session modes — only resize and
  # copy), so we replicate zellij's direct Alt-layer — the keys you hit constantly.
  # herdr actions accept arrays, so these are ADDITIVE: zellij's chords are added
  # alongside herdr's prefix defaults, losing nothing. This is a PARTIAL [keys]
  # table; anything not listed keeps herdr's default — notably copy/scroll stays
  # copy_mode=prefix+[ (== zellij's tmux-style Ctrl+b [) and close_pane=prefix+x
  # (== zellij's pane-mode x).
  #
  # To change a binding, edit this file and rebuild — `herdr config reset-keys`
  # can't rewrite it (it's a read-only Nix-store symlink), which is expected.
  xdg.configFile."herdr/config.toml".text = ''
    # Suppress the first-run/setup tip: herdr normally writes onboarding=false
    # after you dismiss it, but this file is a read-only Nix symlink, so
    # without this line the tip reappears on every startup.
    onboarding = false

    [keys]
    # Pane focus — zellij's Alt+hjkl AND Alt+arrows (prefix nav kept too)
    focus_pane_left = ["prefix+h", "alt+h", "alt+left"]
    focus_pane_down = ["prefix+j", "alt+j", "alt+down"]
    focus_pane_up = ["prefix+k", "alt+k", "alt+up"]
    focus_pane_right = ["prefix+l", "alt+l", "alt+right"]

    # New pane — zellij's Alt+n (herdr's prefix+v vertical split kept)
    split_vertical = ["prefix+v", "alt+n"]

    # Resize — zellij enters resize mode with Ctrl+n (herdr's prefix+r kept)
    resize_mode = ["prefix+r", "ctrl+n"]

    # New tab — herdr's prefix+c plus prefix+t ("t" for tab)
    new_tab = ["prefix+c", "prefix+t"]

    # Desktop notifications when an agent finishes or needs input.
    # "system" = local OS notification; on Linux herdr shells out to notify-send
    # (libnotify, already installed) and needs WAYLAND_DISPLAY (set under the WM).
    [ui.toast]
    delivery = "system"
  '';
}
