{
  description = "Lemon's NixOS";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    master.url = "github:nixos/nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-f2k = {
      url = "github:moni-dz/nixpkgs-f2k";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
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
    config = {
      allowUnfree = true;
    };
    nixpkgs-overlays = ({ inputs, outputs, config, system, ... }: {
      nixpkgs.overlays = [
        (final: _prev: {
          stable = import inputs.nixos {
            system = final.system;
            config = final.config;
          };
          unstable = import inputs.nixpkgs {
            system = final.system;
            config = final.config;
          };
          master = import inputs.master {
            system = final.system;
            config = final.config;
          };
        })
      ];
    });
  in
  {
    nixosConfigurations = {
      # Desktop
      "silver" = nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          nixpkgs-overlays
          ./hosts/silver/default.nix
          ./hosts/silver/user.nix
        ];
      };
      # Laptop (Craptop)
      "aluminum" = nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          nixpkgs-overlays
          ./hosts/aluminum/default.nix
          ./hosts/aluminum/user.nix
        ];
      };
      # Raspberry Pi
      "palladium" = nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          nixpkgs-overlays
          ./hosts/palladium/default.nix
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
