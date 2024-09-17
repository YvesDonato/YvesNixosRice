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

    # Hyprland
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    
    hy3 = {
      url = "github:outfoxxed/hy3";       
      inputs.hyprland.follows = "hyprland";
    };
        
    # Nix colors
    nix-colors.url = "github:misterio77/nix-colors";

    # Cursors Themes
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";

    };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-colors, hyprland, hy3, ... }@inputs:
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
            inherit hy3;
            inherit hyprland;
          };
          
      };
    };
  };
}
