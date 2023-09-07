{ inputs, outputs, pkgs, lib, ...}:
let
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "spotify"
  ];

  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.DefaultDynamic;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      autoSkipVideo
      genre
      loopyLoop
      seekSong
      volumePercentage
    ];
  };
}
