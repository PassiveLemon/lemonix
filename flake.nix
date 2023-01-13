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

  outputs = { self, pkgs, ... }: {
    nixosConfigurations.lemon-tree = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./.nix/hosts/lemon-tree ];
    };
  };
}