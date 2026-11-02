{
  config,
  pkgs,
  desktopWindowManager,
  ...
}: let
  # Launch helium in its own transient systemd user scope: its own cgroup, so
  # oomd sees it as a separate kill candidate (at >=45% swap it kills the leaf
  # using the most swap; session restore brings tabs back) rather than lumped
  # in with the caller, plus a tighter 60% memory-pressure limit. app.slice
  # additionally puts it under the existing memory-pressure monitoring. Helium
  # is Chromium-based, i.e. at least as memory-hungry as the zen setup this
  # replaced, so the scope stays.
  # Extra invocations while helium runs just join the first (scoped) instance.
  helium-scoped = pkgs.writeShellApplication {
    name = "helium-scoped";
    text = ''
      # The 45% swap trigger now also comes from the root slice, which covers
      # every launch path; this wrapper stays for the tighter 60%
      # memory-pressure limit, which fires while the session is stalling.
      run=(systemd-run --user --scope --quiet --collect
        --slice=app.slice -p ManagedOOMSwap=kill
        -p ManagedOOMMemoryPressure=kill -p ManagedOOMMemoryPressureLimit=60% --)
      # Probe first: outside a systemd user session (no user bus), fall back
      # to a direct launch rather than leaving the keybinding dead.
      if "''${run[@]}" true 2>/dev/null; then
        exec "''${run[@]}" helium "$@"
      fi
      exec helium "$@"
    '';
  };
in {
  home.packages = [helium-scoped];

  # Google Messages has no Linux client; its web app in a Helium app window is
  # the official desktop path (pair once via the QR code on the phone). It gets
  # its own profile: an --app launch that starts Helium skips (and then
  # overwrites) the main profile's session restore. Under mango it lives in
  # the Super+S comms group, whose window rule parks any new Messages window
  # out of sight, so the entry opens that group instead.
  xdg.desktopEntries.google-messages = {
    name = "Google Messages";
    exec =
      if desktopWindowManager == "mango"
      then "mango-comms open"
      else "helium-scoped --user-data-dir=${config.home.homeDirectory}/.config/helium-messages --app=https://messages.google.com/web";
    categories = ["Network" "Chat"];
  };

  # Helium ships no Widevine CDM and finds one only through Chromium's Linux
  # hint file; it does not probe the config dir. Verified on 0.15.1.1: the
  # standalone pkgs.widevine-cdm (4.10.2934.0) is read and REJECTED by Chromium
  # 151, while the CDM inside google-chrome (4.10.3050.0, same 151.0.7922.71
  # build) loads and plays DRM. Both declare x-cdm-interface-versions 10, so it
  # is the CDM build that matters. Only this one file is needed -- no CDM tree
  # in the home dir.
  xdg.configFile."net.imput.helium/WidevineCdm/latest-component-updated-widevine-cdm".text = builtins.toJSON {
    Path = "${pkgs.google-chrome}/share/google/chrome/WidevineCdm";
  };
}
