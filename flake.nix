{
  description = "System Flake";

  inputs = {
    # Nixos Packages URLs
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
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
            inherit username;
            inherit name;
            inherit pkgs-unstable;
            inherit inputs;
          };
          
      };
    };
  };
}
