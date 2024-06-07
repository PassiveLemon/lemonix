{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/user.nix
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
