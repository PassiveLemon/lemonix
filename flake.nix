{
  description = "Lemon's NixOS";

  inputs = {
    nixos-old.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    master.url = "github:nixos/nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
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
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Submodules
    awesomewm-bling = {
      url = "github:blingcorp/bling";
      flake = false;
    };
    lite-xl-widget = {
      url = "github:lite-xl/lite-xl-widgets";
      flake = false;
    };
    lite-xl-plugins = {
      url = "github:lite-xl/lite-xl-plugins";
      flake = false;
    };
    lite-xl-lintplus = {
      url = "github:liquidev/lintplus";
      flake = false;
    };
    lite-xl-evergreen = {
      url = "github:evergreen-lxl/evergreen.lxl";
      flake = false;
    };
    lite-xl-treeview-extender = {
      url = "github:juliardi/lite-xl-treeview-extender";
      flake = false;
    };
    lite-xl-lsp = {
      url = "github:lite-xl/lite-xl-lsp";
      flake = false;
    };
  };

  outputs = { self, ... } @ inputs:
  let
    inherit (self) outputs;
    specialArgs = { inherit self inputs outputs; };
    extraSpecialArgs = specialArgs;
  in
  {
    nixosConfigurations = {
      # Desktop
      "silver" = inputs.nixos.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
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
      # SD card died and will be offline for the foreseeable future.
      #"palladium" = inputs.nixos.lib.nixosSystem {
      #  inherit specialArgs;
      #  system = "aarch64-linux";
      #  modules = [
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
          ./users/lemon/common/default.nix
          ./users/lemon/silver/default.nix
          ./users/lemon/silver/home.nix
        ];
      };
      "lemon@aluminum" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit extraSpecialArgs;
        pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        modules = [
          ./users/lemon/common/default.nix
          ./users/lemon/aluminum/default.nix
          ./users/lemon/aluminum/home.nix
        ];
      };
    };

    overlays = import ./overlays { inherit inputs outputs; };
  };
}

