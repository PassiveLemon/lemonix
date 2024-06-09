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
    ./gaming.nix
    ./picom.nix
    ./printing.nix
  ];
}
