{pkgs-unstable, ...}: {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs-unstable; [
    moonlight-qt
    ghostty
    qemu
    tailscale
    discord
    spotify
    helix
    chromedriver
    aichat
    readest
    android-studio
    obsidian
    mpv
    vulkan-hdr-layer-kwin6
  ];
}
