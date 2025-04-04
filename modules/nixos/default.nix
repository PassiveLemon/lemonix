{ config, lib, ... }:
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
    ./agenix.nix
    ./bluetooth.nix
    ./gaming.nix
    ./lanzaboote.nix
    ./ssh.nix
    ./swap.nix
  ];

  config = {
    warnings = mkIf (cfg.system.hibernation.enable && !cfg.swap.enable) [
      "lemonix: Hibernation is enabled but swap is not. Hibernation will not work."
    ];
  
    systemd.services.nix-gc = mkIf cfg.system.mobile.enable {
      unitConfig.ConditionACPower = true;
    };
  };
}

