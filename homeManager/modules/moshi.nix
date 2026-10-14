{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: let
  moshiHook = pkgs-unstable.callPackage ../../packages/moshi-hook.nix {};
  # `moshi-hook install` writes its own resolved path into the agents' hook
  # configs, so it has to run from a real file at a stable path: a store path
  # would break the hooks after an upgrade plus GC. Activation keeps this copy
  # current, and the commands on PATH exec it.
  stableBin = "$HOME/.local/bin/moshi-hook";
  wrapper = name:
    pkgs.writeShellScriptBin name ''
      exec "${stableBin}" "$@"
    '';
in {
  # Moshi (iOS terminal) host side. Declared here instead of `moshi-hook service
  # install`, which would write its own unit. Pairing, settings and agent hooks
  # stay imperative: `moshi-hook host setup`, `moshi-hook set`, `moshi-hook install`.
  # mosh-server and its tailnet-only UDP ports come from configuration.nix.
  home.packages = [(wrapper "moshi-hook") (wrapper "moshi")];

  # `install` unlinks before writing, so replacing the daemon's running binary is safe.
  home.activation.moshiHook = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run install -Dm755 ${moshiHook}/bin/moshi-hook "${stableBin}"
  '';

  systemd.user.services.moshi-hook = {
    Unit = {
      Description = "Moshi hook daemon";
      After = ["network-online.target"];
      # ExecStart is a fixed path, so restart on a version bump explicitly.
      X-Restart-Triggers = ["${moshiHook}"];
    };
    Service = {
      ExecStart = "%h/.local/bin/moshi-hook serve";
      WorkingDirectory = "%h";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };
}
