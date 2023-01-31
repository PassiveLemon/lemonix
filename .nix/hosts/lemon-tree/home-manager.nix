{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];
  home-manager = {
    useGlobalPkgs = true;
    users.lemon = { config, pkgs, ... }: {
      imports = [
        ./configs
        ../../modules/spicetify.nix
      ];
      programs.bash.enable = true;
      services = {
        picom.enable = true;
        dunst.enable = true;
        sxhkd.enable = true;
      };
      home.stateVersion = "22.11";
    };
  };
}