{ config, pkgs, ...}:
let
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  spicetify-nix = (import flake-compat { src = builtins.fetchTarball "https://github.com/the-argus/spicetify-nix/archive/master.tar.gz"; }).defaultNix;
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
in
{
  imports = [ spicetify-nix.homeManagerModule ];
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.DefaultDynamic;
    enabledExtensions = with spicePkgs.extensions; [
      autoSkipVideo
      seekSong
      adblock
    ];
  };
}