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
    xserver.displayManager.importedVariables = [
      "GDK_SCALE"
      "GDK_DPI_SCALE"
      "QT_AUTO_SCREEN_SCALE_FACTOR"
      "QT_ENABLE_HIGHDPI_SCALING"
      "STEAM_FORCE_DESKTOPUI_SCALING"
    ];
  };

  environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_ENABLE_HIGHDPI_SCALING = "1";
    STEAM_FORCE_DESKTOPUI_SCALING = "1";
  };

  systemd = {
    sleep.extraConfig = "HibernateDelaySec=1.5h";
  };
}

