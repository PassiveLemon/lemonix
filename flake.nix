{
  description = "Lemon's NixOS";

  inputs = {
    nixos-old.url = "github:nixos/nixpkgs/nixos-23.11";
    nixos.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    master.url = "github:nixos/nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    specialArgs = { inherit self inputs; };
    extraSpecialArgs = specialArgs;
    config = {
      allowUnfree = true;
    };
    nixpkgs-overlays = ({ inputs, outputs, config, system, ... }: {
      nixpkgs.overlays = [
        (final: prev: {
          # Overlay use of a package on a previous nixos-(stable) branch. Only used for packages that are broken or removed in newer branches.
          old = import inputs.nixos-old {
            system = final.system;
            config = final.config;
          };
          # Overlay use of a package on the nixos-(stable) branch. Mainly used for the system part of the setup.
          stable = import inputs.nixos {
            system = final.system;
            config = final.config;
          };
          # Overlay use of a package on the nixpkgs-unstable branch. Mainly used for the user part of the setup.
          unstable = import inputs.nixpkgs {
            system = final.system;
            config = final.config;
          };
          # Overlay use of a package on the master branch. Only used for packages that are not yet in the unstable or stable branch.
          master = import inputs.master {
            system = final.system;
            config = final.config;
          };
          # Overlay use of a broken package
          broken = import inputs.nixpkgs {
            system = final.system;
            config = final.config // { allowBroken = true; };
          };
        })
      ];
    });
  in
  {
    nixosConfigurations = {
      # Desktop
      "silver" = inputs.nixos.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          nixpkgs-overlays
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          ./hosts/common/default.nix
          ./hosts/silver/default.nix
          ./hosts/silver/system.nix
          ./hosts/silver/user.nix
        ];
      };
      # Framework Laptop
      "aluminum" = inputs.nixos.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          nixpkgs-overlays
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-cpu-amd-raphael-igpu
          inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
          inputs.nixos-hardware.nixosModules.framework-13-7040-amd
          ./hosts/common/default.nix
          ./hosts/aluminum/default.nix
          ./hosts/aluminum/system.nix
          ./hosts/aluminum/user.nix
        ];
      };
      # Raspberry Pi
      # The fucking storage drive died so it's out of commission.
      #"palladium" = inputs.nixos.lib.nixosSystem {
      #  inherit specialArgs;
      #  system = "aarch64-linux";
      #  modules = [
      #    nixpkgs-overlays
      #    inputs.nixos-hardware.nixosModules.common-pc-ssd
      #    inputs.nixos-hardware.nixosModules.raspberry-pi-4
      #    ./hosts/common/default.nix
      #    ./hosts/palladium/default.nix
      #    ./hosts/palladium/system.nix
      #  ];
      #};
    };

    homeConfigurations = {
      "lemon@silver" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit extraSpecialArgs;
        pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        modules = [
          nixpkgs-overlays
          ./users/lemon/common/default.nix
          ./users/lemon/silver/default.nix
          ./users/lemon/silver/home.nix
        ];
      };
      "lemon@aluminum" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit extraSpecialArgs;
        pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        modules = [
          nixpkgs-overlays
          ./users/lemon/common/default.nix
          ./users/lemon/aluminum/default.nix
          ./users/lemon/aluminum/home.nix
        ];
      };
    };

    nixConfig = {
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://passivelemon.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "passivelemon.cachix.org-1:ScYjLCvvLi70S95SMMr8lMilpZHuafLP3CK/nZ9AaXM="
      ];
      extra-experimental-features = [ "nix-command" "flakes" ];
    };
  };
}
