{ ... }: {
  imports = [
    ../common/user.nix
    ../../modules/nixos/bluetooth.nix
  ];

  programs.librepods.enable = true;

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
    XCURSOR_SIZE = "48";
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    QT_SCALE_FACTOR = "2";
    STEAM_FORCE_DESKTOPUI_SCALING = "2";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1.5h";
  };
}

