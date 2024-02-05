{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/user.nix
    ../../modules/nixos/bluetooth.nix
  ];

  services = {
    logind.extraConfig = ''
      HandlePowerKey=suspend
      HandleLidSwitch=suspend-then-hibernate
      IdleAction=ignore
      IdleActionSec=60m
    '';
  };
}
