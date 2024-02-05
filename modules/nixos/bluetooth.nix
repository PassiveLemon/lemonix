{ inputs, outputs, pkgs, config, lib, ... }: {
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
}
