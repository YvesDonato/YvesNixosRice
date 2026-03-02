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

    # Zen Browser
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # opencode.url = "github:anomalyco/opencode/production";
    claude-code.url = "github:sadjow/claude-code-nix";
    codex.url = "github:sadjow/codex-cli-nix";

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
  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;

        modules = [
          ./configuration.nix
        ];

        specialArgs = {
          inherit name;
          inherit pkgs-unstable;
          inherit inputs;
          inherit nix-colors;
        };
      };
    };
    homeConfigurations = {
      yvesd = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit pkgs-unstable;
          inherit username;
        };
        modules = [
          nixvim.homeModules.nixvim
          ./homeManager/home.nix
        ];
      };
    };
  };
}
