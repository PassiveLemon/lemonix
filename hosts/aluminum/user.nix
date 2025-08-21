{ ... }: {
  imports = [
    ../common/user.nix
    ../../modules/nixos/bluetooth.nix
  ];

  location.provider = "geoclue2";
  services = {
    logind = {
      powerKey = "suspend-then-hibernate";
      powerKeyLongPress = "poweroff";
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend-then-hibernate";
      lidSwitchDocked = "suspend-then-hibernate";
    };
    clight.enable = true;
  };

  systemd = {
    sleep.extraConfig = "HibernateDelaySec=2h";
    services.syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}

