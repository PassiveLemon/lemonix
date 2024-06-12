{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/user.nix
    ../../modules/nixos/bluetooth.nix
  ];

  services = {
    logind = {
      powerKey = "suspend-then-hibernate";
      powerKeyLongPress = "poweroff";
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend-then-hibernate";
      lidSwitchDocked = "suspend-then-hibernate";
      extraConfig = ''
        HoldoffTimeoutSec=5s
        IdleAction=suspend
        IdleActionSec=300s
      '';
    };
  };

  systemd = {
    sleep.extraConfig = "HibernateDelaySec=2h";
  };
}
