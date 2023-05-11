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
  };

  outputs = { self, stable, unstable, home-manager, nixpkgs-f2k, ... } @ inputs:
  let
    inherit (self) outputs;
  in
  {
    nixosConfigurations = {
      "lemon-tree" = unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/lemon-tree/default.nix
          home-manager.nixosModules.home-manager
        ];
      };
      "lime-tree" = unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./hosts/lime-tree/default.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
    homeConfigurations = {
      "lemon@lemon-tree" = home-manager.lib.homeManagerConfiguration {
        pkgs = unstable.legacyPackages.x86_64-linux;
        specialArgs = { inherit inputs outputs; };
        modules = [ ./hosts/lemon-tree/home.nix ];
      };
      "lemon@lime-tree" = home-manager.lib.homeManagerConfiguration {
        pkgs = unstable.legacyPackages.x86_64-linux;
        specialArgs = { inherit inputs outputs; };
        modules = [ ./hosts/lime-tree/home.nix ];
      };
    };
  };
}
