{pkgs, ...}: let
  # Launch helium in its own transient systemd user scope so systemd-oomd can
  # act on the browser alone. ManagedOOMSwap=kill makes oomd watch the scope
  # and, at >=90% system swap, kill just helium (session restore brings tabs
  # back) instead of thrashing or taking down the whole login session. app.slice
  # additionally puts it under the existing memory-pressure monitoring. Helium
  # is Chromium-based, i.e. at least as memory-hungry as the zen setup this
  # replaced, so the scope stays.
  # Extra invocations while helium runs just join the first (scoped) instance.
  helium-scoped = pkgs.writeShellApplication {
    name = "helium-scoped";
    text = ''
      # The swap trigger alone is gated on 90% of TOTAL swap, which the 32 GiB
      # disk tier inflated well past the point of usability; the memory-pressure
      # trigger is what actually fires while the session is stalling.
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
