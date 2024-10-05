{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types assertMsg pathExists;
  cfg = config.lemonix;
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
      device = mkOption {
        type = types.path;
        description = "The device to use for swap. Setting this will ignore any swapfile configuration.";
        default = "/var/lib/swapfile";
      };
      zram = {
        enable = mkEnableOption "zram swap";
        memoryPercent = mkOption {
          type = types.int;
          description = "The percent of system memory to use as zram swap.";
          default = 25;
        };
      };
    };
  };

  config = {
    warnings = mkIf ((cfg.swap.device == "/var/lib/swapfile") && cfg.system.hibernation.enable) [
      "lemonix: Hibernation may not work with a swap file, specify a swap partition with config.lemonix.swap.device instead."
    ];
    assertions = [
      {
        assertion = !(cfg.swap.zram.enable && cfg.system.hibernation.enable);
        message = "lemonix: Zram swap cannot be used with hibernation.";
      }
    ];

    boot.resumeDevice = mkIf (cfg.swap.enable && (cfg.swap.device != "/var/lib/swapfile")) cfg.swap.device;

    swapDevices = mkIf (cfg.swap.enable && (cfg.swap.device == "/var/lib/swapfile")) [
      {
        device = "/var/lib/swapfile";
        size = (cfg.swap.size * 1024);
        priority = 50;
        randomEncryption.enable = !cfg.system.hibernation.enable;
      }
    ];

    zramSwap = mkIf cfg.swap.zram.enable {
      enable = true;
      memoryPercent = cfg.swap.zram.memoryPercent;
      priority = 100;
    };
  };
}

