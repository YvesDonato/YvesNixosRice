{pkgs, ...}: let
  # Launch zen in its own transient systemd user scope so systemd-oomd can act
  # on the browser alone. ManagedOOMSwap=kill makes oomd watch the scope and,
  # at >=90% system swap, kill just zen (session restore brings tabs back)
  # instead of thrashing or taking down the whole login session. app.slice
  # additionally puts it under the existing memory-pressure monitoring.
  # Extra invocations while zen runs just join the first (scoped) instance.
  zen-scoped = pkgs.writeShellApplication {
    name = "zen-scoped";
    text = ''
      run=(systemd-run --user --scope --quiet --collect
        --slice=app.slice -p ManagedOOMSwap=kill --)
      # Probe first: outside a systemd user session (no user bus), fall back
      # to a direct launch rather than leaving the keybinding dead.
      if "''${run[@]}" true 2>/dev/null; then
        exec "''${run[@]}" zen-beta "$@"
      fi
      exec zen-beta "$@"
    '';
  };
in {
  home.packages = [zen-scoped];
}
