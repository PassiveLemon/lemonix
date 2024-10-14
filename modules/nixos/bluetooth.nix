{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.lemonix.bluetooth;
in
{
  options = {
    lemonix.bluetooth = {
      enable = mkEnableOption "bluetooth";
    };
  };

  config = mkIf cfg.enable {
    services.blueman.enable = true;

    hardware.bluetooth.enable = true;
  };
}

