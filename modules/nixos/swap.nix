{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.lemonix.swap;
in
{
  options = {
    lemonix.swap = {
      enable = mkEnableOption "swap";

      size = mkOption {
        type = types.int;
        description = "The size of the swapfile in GiB.";
        default = 16;
      };

      zram = {
        enable = mkEnableOption "zram swap";

        memoryPercent = mkOption {
          type = types.int;
          description = "The percent of RAM to use as zram swap.";
          default = 25;
        };
      };
    };
  };

  config = {
    swapDevices = mkIf cfg.enable [
      {
        device = "/var/lib/swapfile";
        size = (cfg.size * 1024);
        priority = 50;
        randomEncryption.enable = true;
      }
    ];

    zramSwap = mkIf cfg.zram.enable {
      enable = true;
      memoryPercent = cfg.zram.memoryPercent;
      priority = 100;
    };
  };
}
