{ pkgs, ... }: {
  imports = [
    ../common/user.nix
  ];

  # Configs
  services = {
    udev.packages = with pkgs; [
      headsetcontrol
    ];
    flatpak.enable = true;
  };
}

