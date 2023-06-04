{
  description = "Lemons Nix";

  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-22.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager"; 
      inputs.nixpkgs.follows = "unstable";
    };

    # User repos
    nixpkgs-f2k.url = "github:fortuneteller2k/nixpkgs-f2k";
    spicetify-nix.url = github:the-argus/spicetify-nix;
  };

  outputs = { self, stable, unstable, home-manager, nixpkgs-f2k, spicetify-nix, ... }@inputs:
  let
    inherit (self) outputs;
  in
  {
    nixosConfigurations = {
      "lemon-tree" = unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [ ./hosts/lemon-tree/default.nix ];
      };
      "lime-tree" = unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [ ./hosts/lime-tree/default.nix ];
      };
    };
    homeConfigurations = {
      "lemon@lemon-tree" = home-manager.lib.homeManagerConfiguration {
        pkgs = unstable.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./users/lemon/desktophome.nix
          spicetify-nix.homeManagerModule
        ];
      };
      "lemon@lime-tree" = home-manager.lib.homeManagerConfiguration {
        pkgs = unstable.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./users/lime/laptophome.nix
        ];
      };
    };
  };
}
