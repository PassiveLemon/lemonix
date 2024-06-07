{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/user.nix
    ../../modules/nixos/bluetooth.nix
  ];

  services = {
    xserver.dpi = 200;
      logind.extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      HandlePowerKeyLongPress=poweroff
      HandleLidSwitch=suspend-then-hibernate
      HandleLidSwitchExternalPower=suspend-then-hibernate
      HandleLidSwitchDocked=suspend-then-hibernate
      HoldoffTimeoutSec=5s
      IdleAction=suspend
      IdleActionSec=300s
    '';
  };
}
