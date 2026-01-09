{ ... }: {
  imports = [
    ../common/user.nix
    ../../modules/nixos/bluetooth.nix
  ];

  location.provider = "geoclue2";
  services = {
    logind.settings.Login = {
      HandlePowerKey = "suspend-then-hibernate";
      HandlePowerKeyLongPress = "poweroff";
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
      HandleLidSwitchDocked = "suspend-then-hibernate";
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
    XCURSOR_SIZE = "32";
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

