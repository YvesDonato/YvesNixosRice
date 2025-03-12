{pkgs-unstable, ...}: {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs-unstable; [
    leetgo
    moonlight-qt
    ghostty
    qemu
    tailscale
    webcord-vencord
    spotify
  ];
}
