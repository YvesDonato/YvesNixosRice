{
  description = "System Flake";

  inputs = {
    # Nixos Packages URLs
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";

    # Zen Browser
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    claude-code.url = "github:sadjow/claude-code-nix";
    codex.url = "github:sadjow/codex-cli-nix";

    linuxmis = {
      url = "github:YvesDonato/Linuxmis";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Nix colors
    nix-colors.url = "github:misterio77/nix-colors";

    # Cursors Themes
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nix-colors,
    nixvim,
    quickshell,
    ...
  } @ inputs: let
    # System
    system = "x86_64-linux";
    username = "yvesd";
    name = "Yves";
    # Valid values: "hyprland" or "mango".
    desktopWindowManager = "mango";

    # Nixos Packages Settings
    # Stable
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # Unstable
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    piCodingAgent = pkgs-unstable.callPackage ./packages/pi-coding-agent.nix {};

    mkNixosConfiguration = wm:
      lib.nixosSystem {
        inherit system;

        modules = [
          ./configuration.nix
        ];

        specialArgs = {
          inherit name;
          inherit pkgs-unstable;
          inherit inputs;
          inherit nix-colors;
          inherit piCodingAgent;
          desktopWindowManager = wm;
        };
      };

    mkHomeConfiguration = wm:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit pkgs-unstable;
          inherit username;
          inherit inputs;
          desktopWindowManager = wm;
        };
        modules = [
          ./homeManager/home.nix
        ];
      };
  in {
    nixosConfigurations = {
      nixos = mkNixosConfiguration desktopWindowManager;
      "nixos-mango" = mkNixosConfiguration "mango";
      "nixos-hyprland" = mkNixosConfiguration "hyprland";
    };
    homeConfigurations = {
      yvesd = mkHomeConfiguration desktopWindowManager;
      "yvesd-mango" = mkHomeConfiguration "mango";
      "yvesd-hyprland" = mkHomeConfiguration "hyprland";
    };
    packages.${system} = {
      pi-coding-agent = piCodingAgent;
    };
  };
}
