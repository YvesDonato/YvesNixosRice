{
  description = "System Flake";

  inputs = {
    # Nixos Packages URLs
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # Nix colors
    nix-colors.url = "github:misterio77/nix-colors";

    # Cursors Themes
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NVF
    # nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nix-colors,
    hyprland,
    nixvim,
    # nvf,
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
          # inherit username;
          inherit name;
          inherit pkgs-unstable;
          inherit inputs;
          inherit nix-colors;
          inherit hyprland;
        };
      };
    };
    homeConfigurations = {
      mee = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit username;
        };
        modules = [
          nixvim.homeManagerModules.nixvim
          # nvf.homeManagerModules.default
          ./home.nix
        ];
      };
    };
  };
}
