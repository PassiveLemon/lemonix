{
  description = "Lemon's NixOS";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.05";

    # User repos
    nixpkgs-f2k.url = "github:fortuneteller2k/nixpkgs-f2k";
    spicetify-nix.url = github:the-argus/spicetify-nix;
  };

  outputs = inputs:
  with inputs;
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    specialArgs = { inherit self inputs; };
    extraSpecialArgs = specialArgs;
  in
  {
    nixosConfigurations = {
      "lemon-tree" = nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/lemon-tree/default.nix
          ./hosts/lemon-tree/user.nix
        ];
      };
      "lime-tree" = nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/lime-tree/default.nix
          ./hosts/lime-tree/user.nix
        ];
      };
    };
    homeConfigurations = {
      "lemon@lemon-tree" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./users/lemon/desktophome.nix
          spicetify-nix.homeManagerModule
        ];
      };
      "lemon@lime-tree" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./users/lime/laptophome.nix
        ];
      };
    };
  };
}
