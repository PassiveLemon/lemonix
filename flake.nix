{
  description = "PassiveLemon NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix.url = "github:the-argus/spicetify-nix";
  };

  outputs = { self, nixpkgs, home-manager, spicetify-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;

    in {
      homeManagerConfigurations.lemon = home-manager.lib.homeManagerConfiguration {
        modules = [
          ./.nix/home-manager/home.nix
          spicetify-nix.homeManagerModule
        ];
      };
      nixosConfigurations.lemon-tree = nixpkgs.lib.nixosSystem {
        modules = [
          ./.nix/hosts/lemon-tree/default.nix
          #./.nix/modules/home-manager/home.nix
        ];
      };
    };
}