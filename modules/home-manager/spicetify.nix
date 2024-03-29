{ inputs, pkgs, config, lib, ... }:
let
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in
{
  nixpkgs = {
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "spotify"
    ];
  };

  programs = {
    spicetify = {
      enable = true;
      theme = spicePkgs.themes.DefaultDynamic;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        autoSkipVideo
        #genre https://github.com/the-argus/spicetify-nix/issues/50
        loopyLoop
        seekSong
        volumePercentage
      ];
    };
  };
}
