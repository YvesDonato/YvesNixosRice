{
  description = "System Flake";

  inputs = {
    # Nixos Packages URLs
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hyprland
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    hy3 = {
      url = "github:outfoxxed/hy3?ref=hl0.45.0"; # where {version} is the hyprland release version
      inputs.hyprland.follows = "hyprland";
    };
    
    # Nix colors
    nix-colors.url = "github:misterio77/nix-colors";

    # Cursors Themes
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";

    };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-colors, hyprland, hy3, nixvim, ... }@inputs:
    let
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
            inherit username; inherit nixvim;
          };
          modules = [
            ./home.nix
           home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.sharedModules = [
              ];
            }
          ];
        };
      };
 };
}
