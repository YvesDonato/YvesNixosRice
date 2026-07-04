{
  pkgs-unstable,
  inputs,
  piCodingAgent,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs-unstable; [
    moonlight-qt
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
    inputs.linuxmis.packages."${stdenv.hostPlatform.system}".linuxmis
    inputs.claude-code.packages."${stdenv.hostPlatform.system}".default
    inputs.codex.packages."${stdenv.hostPlatform.system}".default
    inputs.herdr.packages."${stdenv.hostPlatform.system}".default
    piCodingAgent
    audacity
    parsec-bin
    flutter
    freecad
    python3Packages.huggingface-hub # Hugging Face CLI (`hf` / `huggingface-cli`)
    # `az` with extensions bundled (`az network bastion ssh --auth-type AAD`); runtime
    # `pip` extension installs fail on the wrapped CLI, so bundle declaratively. bastion
    # provides the `network bastion ssh/tunnel/rdp` commands; ssh is required by the
    # AAD auth path (bastion's ssh_bastion_host calls _test_extension("ssh")).
    (azure-cli.withExtensions [
      azure-cli.extensions.bastion
      azure-cli.extensions.ssh
    ])
  ];
}
