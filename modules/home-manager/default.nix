{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.lemonix;
in
{
  options = {
    lemonix = {
      system = {
        mobile.enable = mkEnableOption "mobile configuration";
        server.enable = mkEnableOption "server configuration";
        hibernation.enable = mkEnableOption "hibernation configuration";
        headless.enable = mkEnableOption "headless configuration";
      };
    };
  };

  imports = [
    ./gaming.nix
    ./modeling.nix
  ];

  config = { };
}

