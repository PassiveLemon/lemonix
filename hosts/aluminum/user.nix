{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/user.nix
    ../../modules/nixos/bluetooth.nix
  ];

  # Configs
  services = {
    logind.extraConfig = ''
      HandlePowerKey=suspend
      HandleLidSwitch=suspend-then-hibernate
      IdleAction=ignore
      IdleActionSec=60m
    '';
  };
}
