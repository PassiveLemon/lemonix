{
  description = "Lemons Nix";

  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-22.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-22.11"; 
    home-manager.inputs.nixpkgs.follows = "stable";

    nixpkgs-f2k.url = "github:fortuneteller2k/nixpkgs-f2k";
  };

  outputs = { self, stable, unstable, home-manager, nixpkgs-f2k, ... } @ inputs: {
    nixosConfigurations = {
      "lemon-tree" = stable.lib.nixosSystem {
        specialArgs = { inherit nixpkgs-f2k; };
        system = "x86_64-linux";
        modules = [
          ./hosts/lemon-tree/hardware-configuration.nix
          ./hosts/lemon-tree/default.nix
          ./hosts/lemon-tree/user.nix
        ];
      };

      "lime-tree" = stable.lib.nixosSystem {
        specialArgs = { inherit nixpkgs-f2k; };
        system = "x86_64-linux";
        modules = [
          ./hosts/lime-tree/hardware-configuration.nix
          ./hosts/lime-tree/default.nix
          ./hosts/lime-tree/user.nix
        ];
      };
    };

    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    homeConfigurations = {
      lemon = home-manager.lib.homeManagerConfiguration {
        pkgs = import stable { system = "x86_64-linux"; };
        modules = [ ./hosts/lemon-tree/home.nix ];
      };
    };
  };
}
