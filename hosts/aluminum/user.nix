{ ... }: {
  imports = [
    ../common/user.nix
    ../../modules/nixos/bluetooth.nix
  ];

  programs = {
    librepods.enable = true;
  };

  location.provider = "geoclue2";
  services = {
    logind.settings.Login = {
      HandlePowerKey = "suspend-then-hibernate";
      HandlePowerKeyLongPress = "poweroff";
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
      HandleLidSwitchDocked = "suspend-then-hibernate";
    };
  };

  environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_ENABLE_HIGHDPI_SCALING = "1";
    STEAM_FORCE_DESKTOPUI_SCALING = "1.5";
  };

  systemd = {
    sleep.settings.Sleep = {
      HibernateDelaySec = "1.5h";
    };
  };
}

