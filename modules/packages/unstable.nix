{
  pkgs-unstable,
  inputs,
  piCodingAgent,
  ...
}: let
  codexPackage = inputs.codex.packages."${pkgs-unstable.stdenv.hostPlatform.system}".default;
  codexWrapped = codexPackage.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs-unstable.makeWrapper];
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        # Herdr sees codex-raw after the upstream wrapper execs. Keep the
        # documented agent hint scoped to Codex so the pane is still detected.
        # Plugin lifecycle hooks inherit this PATH and require a node fallback.
        wrapProgram $out/bin/codex \
          --set-default HERDR_AGENT codex \
          --suffix PATH : ${pkgs-unstable.lib.makeBinPath [pkgs-unstable.nodejs]}
      '';
  });
in {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs-unstable; [
    moonlight-qt
    vesktop # native-Wayland Discord client; official `discord` was unstable on Linux
    spotify
    aichat
    readest
    obsidian
    (mpv.override {
      yt-dlp = yt-dlp.override {
        javascriptSupport = false;
      };
    })
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
    codexWrapped
    inputs.herdr.packages."${stdenv.hostPlatform.system}".default
    inputs.helium.packages."${stdenv.hostPlatform.system}".default
    piCodingAgent
    audacity
    parsec-bin
    flutter
    bambu-studio
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
