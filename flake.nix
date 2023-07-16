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
      "silver" = nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/silver/default.nix
          ./hosts/silver/user.nix
        ];
      };
      "aluminum" = nixos.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/aluminum/default.nix
          ./hosts/aluminum/user.nix
        ];
      };
    };
    homeConfigurations = {
      "lemon@silver" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./users/lemon/silver/home.nix
          spicetify-nix.homeManagerModule
        ];
      };
      "lemon@aluminum" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./users/lemon/aluminum/home.nix
          spicetify-nix.homeManagerModule
        ];
      };
    };
  };
}
