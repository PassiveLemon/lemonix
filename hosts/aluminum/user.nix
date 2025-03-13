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
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      dataDir = "/home/lemon";
      configDir = "/home/lemon/.config/syncthing";
      user = "lemon";
      group = "users";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        gui = {
          user = "RI43dPf7R4CcgvvjjF38O";
          password = "wn2gWn1TEqizQroDh@7Je";
        };
        devices = {
          "Silver" = { id = "RJUPLXU-KS7PLLI-6OTXT22-W26HMRO-RXMFJ5G-2KU6FEM-G54HQ4D-LXWRBA4"; };
          "Aluminum" = { id = "ISH2V3D-ITIYVOE-I6FUGCD-6NQT6VQ-5N2ZG3S-HQOEFI5-ZEDAADF-CJ3OIQ7"; };
        };
        folders = {
          "Shared" = {
            path = "/home/lemon/Shared";
            devices = [ "Silver" "Aluminum" ];
          };
        };
      };
    };
  };

  systemd = {
    sleep.extraConfig = "HibernateDelaySec=2h";
    services.syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}

