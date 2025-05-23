{
  description = "Lemon's NixOS";

  inputs = {
    nixos-old.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    master.url = "github:nixos/nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lemonake = {
      url = "github:passivelemon/lemonake";
      # url = "path:/home/lemon/Documents/GitHub/lemonake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-f2k = {
      url = "github:moni-dz/nixpkgs-f2k";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
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
    nix-xl = {
      # url = "github:passivelemon/nix-xl";
      url = "path:/home/lemon/Documents/GitHub/nix-xl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Submodules
    awesomewm-bling = {
      url = "github:passivelemon/bling/flatpak-fix";
      flake = false;
    };
    lite-xl-plugins = {
      url = "github:lite-xl/lite-xl-plugins";
      flake = false;
    };
    hilbish-promptua = {
      url = "github:passivelemon/promptua";
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
      # Would be on NixOS, but OpenComposite has been having issues...
      "silver" = inputs.nixpkgs.lib.nixosSystem {
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

    devShells.x86_64-linux = let
      pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    in
    {
      default = self.devShells.x86_64-linux.docker;
      docker = pkgs.mkShell {
        packages = with pkgs; [
          act dive trivy
        ];
      };
    };
  };
}

