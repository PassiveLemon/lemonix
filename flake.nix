{
  description = "Lemon's NixOS";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    master.url = "github:nixos/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User repos
    nixpkgs-f2k = {
      url = "github:fortuneteller2k/nixpkgs-f2k";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = github:the-argus/spicetify-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
  with inputs;
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    specialArgs = { inherit self inputs; };
    extraSpecialArgs = specialArgs;
    nixpkgs-overlays = ({ inputs, outputs, config, system, ... }: {
      nixpkgs.overlays = [
        (final: _prev: {
          unstable = import inputs.unstable {
            system = final.system;
            config.allowUnfree = true;
          };
          master = import inputs.master {
            system = final.system;
            config.allowUnfree = true;
          };
        })
      ];
    });
  in
  {
    nixosConfigurations = {
      "silver" = nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          nixpkgs-overlays
          ./hosts/silver/default.nix
          ./hosts/silver/user.nix
        ];
      };
      "aluminum" = nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          nixpkgs-overlays
          ./hosts/aluminum/default.nix
          ./hosts/aluminum/user.nix
        ];
      };
    };
    homeConfigurations = {
      "lemon@silver" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          nixpkgs-overlays
          ./users/lemon/silver/home.nix
          spicetify-nix.homeManagerModule
        ];
      };
      "lemon@aluminum" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          nixpkgs-overlays
          ./users/lemon/aluminum/home.nix
          spicetify-nix.homeManagerModule
        ];
      };
    };
  };
}
