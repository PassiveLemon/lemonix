{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
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
        specs = {
          cpu = mkOption {
            type = types.int;
            description = "The amount of CPU threads.";
          };
          gpu = mkOption {
            type = types.enum [ "none" "nvidia" "amd" "amd-igpu" "intel" "intel-igpu" ];
            description = "The graphics processing device.";
          };
          memory = mkOption {
            type = types.int;
            description = "The amount of system memory in whole gigabytes.";
          };
        };
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
    warnings = mkIf (cfg.system.hibernation.enable && cfg.swap.enable) [
      "lemonix: Hibernation is enabled but swap is not. Hibernation will not work."
    ];
  
    systemd.services.nix-gc = mkIf cfg.system.mobile.enable {
      unitConfig.ConditionACPower = true;
    };

    nix = (
      if cfg.system.specs.cpu <= 4
      then {
        settings = {
          cores = 3;
          max-jobs = 1;
        };
      }
      else {
        settings = {
          cores = ((cfg.system.specs.cpu - 2) / 2);
          max-jobs = 2;
        };
      }
    );
  };
}

