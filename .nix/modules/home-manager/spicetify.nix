{ pkgs, unstable, lib, spicetify-nix, ... }: {
  # allow spotify to be installed if you don't have unfree enabled already
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify-unwrapped"
  ];

  # import the flake's module for your system
  imports = [ spicetify-nix.homeManagerModule ];
}