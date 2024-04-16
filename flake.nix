{
  description = "Lemon's NixOS";

  inputs = {
    nixos-old.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    master.url = "github:nixos/nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-xr = {
      url = "github:nix-community/nixpkgs-xr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lemonake = {
      url = "github:passivelemon/lemonake";
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

    # Temp
    envision = {
      url = "gitlab:scrumplex/envision/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... } @ inputs:
  let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs { inherit system; };
    specialArgs = { inherit self inputs; };
    extraSpecialArgs = specialArgs;
    config = {
      allowUnfree = true;
    };
    nixpkgs-overlays = ({ inputs, outputs, config, system, ... }: {
      nixpkgs.overlays = [
        (final: _prev: {
          old = import inputs.nixos-old {
            system = final.system;
            config = final.config;
          };
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
      "silver" = inputs.nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          nixpkgs-overlays
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          ./hosts/silver/default.nix
          ./hosts/silver/user.nix
        ];
      };
      # Laptop
      "aluminum" = inputs.nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          nixpkgs-overlays
          inputs.nixos-hardware.nixosModules.common-cpu-intel
          inputs.nixos-hardware.nixosModules.common-gpu-intel
          inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
          ./hosts/aluminum/default.nix
          ./hosts/aluminum/user.nix
        ];
      };
      # Raspberry Pi
      "palladium" = inputs.nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          nixpkgs-overlays
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.nixos-hardware.nixosModules.raspberry-pi-4
          ./hosts/palladium/default.nix
        ];
      };
    };
    homeConfigurations = {
      "lemon@silver" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          nixpkgs-overlays
          ./users/lemon/silver/home.nix
        ];
      };
      "lemon@aluminum" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          nixpkgs-overlays
          ./users/lemon/aluminum/home.nix
        ];
      };
    };

    nixConfig = {
      extra-substituters = [ "https://passivelemon.cachix.org" ];
      extra-trusted-public-keys = [ "passivelemon.cachix.org-1:ScYjLCvvLi70S95SMMr8lMilpZHuafLP3CK/nZ9AaXM=" ];
    };
  };
}
