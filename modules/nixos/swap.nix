{ config, lib, ... }:

# This module only accepts swapfiles at /var/lib/swapfile, unexpected behaviour may happen if the swapfile is set at a different place.

let
  inherit (lib) mkIf mkEnableOption mkOption types;
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
      zswap = {
        enable = mkEnableOption "zswap";
        memoryPercent = mkOption {
          type = types.int;
          description = "The percent of system memory to use as zswap.";
          default = 25;
        };
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = !((cfg.swap.device == "/var/lib/swapfile") && cfg.system.hibernation.enable);
        # The swap file should also be at least exactly as large as the system memory and ideally a little bigger.
        message = "lemonix: Hibernation will not work with a swap file, specify a swap partition with lemonix.swap.device instead.";
      }
      {
        assertion = !(cfg.swap.zram.enable && cfg.system.hibernation.enable);
        message = "lemonix: Zram swap cannot be used with hibernation.";
      }
      {
        assertion = !(cfg.swap.zram.enable && cfg.swap.zswap.enable);
        message = "lemonix: Zram and Zswap should not both be enabled. Choose one.";
      }
    ];

    boot = {
      resumeDevice = mkIf (cfg.swap.enable && (cfg.swap.device != "/var/lib/swapfile")) cfg.swap.device;
      kernelParams = mkIf cfg.swap.zswap.enable [
        "zswap.enabled=1"
        "zswap.max_pool_percent=${builtins.toString cfg.swap.zswap.memoryPercent}"
        "zswap.compressor=lz4"
        "zswap.shrinker_enabled=1"
      ];
      initrd.systemd.enable = mkIf cfg.swap.zswap.enable true;
    };

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

