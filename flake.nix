{
  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
           inherit system;
           config.allowUnfree = true;
         };
      pkgs-unstable = import nixpkgs-unstable {
           inherit system;
           config.allowUnfree = true;
         };
      username = "yvesd";
      name = "Yves";
    in {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          modules = [ ./configuration.nix ];
          specialArgs = {
            inherit username;
            inherit name;
            inherit pkgs-unstable;
        };
      };
    };
  };
}
