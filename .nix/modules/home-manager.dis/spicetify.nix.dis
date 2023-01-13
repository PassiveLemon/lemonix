{ pkgs, unstable, lib, spicetify-nix, ... }:
let
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
in
{
  # allow spotify to be installed if you don't have unfree enabled already
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify"
  ];

  # import the flake's module for your system
  imports = [ spicetify-nix.homeManagerModules.default ];

  programs = {
    spicetify = {
      enable = true;
      theme = spicePkgs.themes.catppuccin-mocha;
      colorScheme = "flamingo";
      spotifyPackage = unstable.spotify-unwrapped;
      enabledExtensions = with spicePkgs.extensions; [
        "fullAppDisplay.js"
        "shuffle+.js"
        "adblock"
        "hidePodcasts"
    ];
  };
}