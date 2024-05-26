{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/user.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/gaming.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      distrobox
    ];
  };

  # Configs
  services = {
    udev.packages = with pkgs; [
      headsetcontrol
    ];
  };
}
