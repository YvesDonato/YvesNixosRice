
{pkgs, inputs, ...}: {
  environment.systemPackages = with pkgs; [
    # Programs
    inputs.zen-browser.packages."${stdenv.hostPlatform.system}".default
    chromium
    anki
    rofi
    pavucontrol
    pamixer
    blanket
    libreoffice
    obs-studio
    blueman
    crispy-doom
    sqlitebrowser

    # Zsh
    starship

    # Terminal
    neovim
    git
    neofetch
    wget
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
    fd
    python313Packages.weasyprint
    unzip
    p7zip
    pandoc

    # Languages
    alejandra
    ruff
    clang
    svelte-language-server
    typescript-language-server
    tailwindcss-language-server
    glibc
    zlib
    marksman

    # mongosh
    # mongodb
       
    # system
    xwayland
    brightnessctl
    gnome-disk-utility
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
    swtpm
    dex
    transmission_4

    glib
    nss
    nspr
  ];
}
