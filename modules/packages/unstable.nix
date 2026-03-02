{pkgs-unstable, inputs, ...}: {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs-unstable; [
    moonlight-qt
    ghostty
    qemu
    tailscale
    discord
    spotify
    chromedriver
    aichat
    readest
    android-studio
    obsidian
    mpv
    remmina
    vulkan-hdr-layer-kwin6
    lazyssh
    presenterm
    d2
    mermaid-cli
    typst
    termscp
    aider-chat
    zed-editor-fhs
    teams-for-linux
    sshfs-fuse
    zellij
    inputs.claude-code.packages."${stdenv.hostPlatform.system}".default
    # inputs.opencode.packages."${stdenv.hostPlatform.system}".default
    inputs.codex.packages."${stdenv.hostPlatform.system}".default
    audacity
  ];
}
