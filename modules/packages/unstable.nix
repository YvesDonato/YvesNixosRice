{
  pkgs-unstable,
  inputs,
  piCodingAgent,
  ...
}: {
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
    obsidian
    (mpv.override {
      yt-dlp = yt-dlp.override {
        javascriptSupport = false;
      };
    })
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
    inputs.linuxmis.packages."${stdenv.hostPlatform.system}".linuxmis
    inputs.claude-code.packages."${stdenv.hostPlatform.system}".default
    inputs.codex.packages."${stdenv.hostPlatform.system}".default
    piCodingAgent
    audacity
    parsec-bin
    flutter
    freecad
  ];
}
