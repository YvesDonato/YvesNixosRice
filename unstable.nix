{pkgs-unstable, ...}: {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs-unstable; [
    electron
    hypridle
    lsp-ai
    psst
    smassh
    leetgo
    moonlight-qt
    aichat
    ghostty
  ];
}
