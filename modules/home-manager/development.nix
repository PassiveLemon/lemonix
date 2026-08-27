{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.lemonix.development;
in
{
  options = {
    lemonix.development = {
      enable = mkEnableOption "development modules";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ltspice
      # digital
      # scilab-bin
    ];
  };
}

