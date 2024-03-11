{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/user.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/gaming.nix
  ];

  # Configs
  services = {
    udev.extraRules = ''
      ACTION!="add|change", GOTO="headset_end"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1b1c", ATTRS{idProduct}=="0a51", TAG+="uaccess"
      LABEL="headset_end"
    ''; # Headsetcontrol udev rule
  };
}
