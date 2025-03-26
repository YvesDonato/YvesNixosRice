{pkgs-unstable, ...}: {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs-unstable; [
    leetgo
    moonlight-qt
    ghostty
    qemu
    tailscale
    discord
    spotify
  ];
}
