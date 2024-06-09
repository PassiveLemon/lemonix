{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.lemonix;
in
{
  options = {
    lemonix = {
    };
  };

  imports = [
    ./bluetooth.nix
    ./gaming.nix
    ./lanzaboote.nix
    ./ssh.nix
    ./swap.nix
  ];
}
