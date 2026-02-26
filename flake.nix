{
  inputs = {
    nixos-old.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos.url = "github:nixos/nixpkgs/nixos-25.11";
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
    nix-xl = {
      url = "github:passivelemon/nix-xl";
      # url = "path:/home/lemon/Documents/GitHub/nix-xl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
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
      url = "github:passivelemon/bling";
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
    # Not the ideal place to define system but all my machines are the same arch so it works
    system = "x86_64-linux";
    specialArgs = {
      inherit self inputs outputs system;
    };
    extraSpecialArgs = specialArgs;
  in
  {
    nixosConfigurations = {
      # Desktop
      "silver" = inputs.nixos.lib.nixosSystem {
        inherit system specialArgs;
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
        inherit system specialArgs;
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
      # Homeserver
      "titanium" = inputs.nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          # Doesn't currently have a GPU but one may be added in the future for transcoding and whatnot
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          ./hosts/common/default.nix
          ./hosts/titanium/default.nix
          ./hosts/titanium/system.nix
        ];
      };
    };

    homeConfigurations = {
      "lemon@silver" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit extraSpecialArgs;
        pkgs = import inputs.nixpkgs { inherit system; };
        modules = [
          ./users/lemon/common/default.nix
          ./users/lemon/silver/default.nix
          ./users/lemon/silver/home.nix
        ];
      };
      "lemon@aluminum" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit extraSpecialArgs;
        pkgs = import inputs.nixpkgs { inherit system; };
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
    packages.x86_64-linux = let
      pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    in
    {
      rd-titanium = pkgs.writeShellApplication {
        name = "update";
        text = ''
          nixos-rebuild switch --flake .#titanium --target-host root@titanium
        '';
      };
    };
  };
}

