{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/user.nix
  ];

  # Configs
  services = {
    udev.packages = with pkgs; [
      headsetcontrol
    ];
  };
}
