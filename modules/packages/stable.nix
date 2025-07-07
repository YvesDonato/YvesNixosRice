
{pkgs, inputs, ...}: {
  environment.systemPackages = with pkgs; [
    # Programs
    inputs.zen-browser.packages."${system}".default
    chromium
    anki
    rofi-wayland
    nautilus
    pavucontrol
    pamixer
    blanket
    libreoffice
    obs-studio
    vlc
    tailscale
    blueman
    pomodoro-gtk

    # Zsh
    starship

    # Terminal
    neovim
    zellij
    git
    neofetch
    wget
    spotify-cli-linux
    killall
    btop
    tlp
    git-credential-manager
    wlr-randr
    lsof
    yazi
    asusctl
    supergfxctl
    lshw
    glow
    curl
    acpi
    patchelf
    leetcode-cli
    gitui
   
    # Languages
    alejandra
    ruff
    clang
    svelte-language-server
    typescript-language-server
    tailwindcss-language-server
    glibc
    zlib
   
    # system
    xwayland
    brightnessctl
    gnome-disk-utility
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    swtpm
    dex
    transmission
  ];
}
