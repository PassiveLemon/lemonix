{
  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    master.url = "github:nixos/nixpkgs/master";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/master";
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
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Until i put it in lemonake
    outsource = {
      url = "github:passivelemon/outsource";
      # url = "path:/home/lemon/Documents/GitHub/outsource";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Submodules
    awesomewm-bling = {
      url = "github:passivelemon/bling";
      # url = "path:/home/lemon/Documents/GitHub/bling";
      flake = false;
    };
    hilbish-promptua = {
      url = "github:passivelemon/promptua";
      # url = "path:/home/lemon/Documents/GitHub/Promptua";
      flake = false;
    };
  };

  outputs = { self, ... } @ inputs: let
    inherit (self) outputs;

    mkNixOS = name: system: inputs.nixos.lib.nixosSystem {
      system = system;
      specialArgs = { inherit self inputs outputs system; };
      modules = [
        ./hosts/common/default.nix
        ./hosts/${name}/default.nix
        ./hosts/${name}/system.nix
        ./hosts/${name}/user.nix
      ];
    };

    mkHome = name: host: let
      # Use the system from the host, but without having to use home-manager as a NixOS module
      system = self.nixosConfigurations.${host}.pkgs.stdenv.hostPlatform.system;
    in inputs.home-manager.lib.homeManagerConfiguration {
      extraSpecialArgs = { inherit self inputs outputs system; };
      pkgs = import inputs.nixpkgs { inherit system; };
      modules = [
        ./users/${name}/common/default.nix
        ./users/${name}/${host}/default.nix
        ./users/${name}/${host}/home.nix
      ];
    };
  in {
    nixosConfigurations = {
      # Desktop
      "silver" = mkNixOS "silver" "x86_64-linux";
      # Framework Laptop
      "aluminum" = mkNixOS "aluminum" "x86_64-linux";
      # Homeserver
      "titanium" = mkNixOS "titanium" "x86_64-linux";
    };
    homeConfigurations = {
      "lemon@silver" = mkHome "lemon" "silver";
      "lemon@aluminum" = mkHome "lemon" "aluminum";
    };
  };
}

