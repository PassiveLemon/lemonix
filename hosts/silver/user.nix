{ ... }: {
  imports = [
    ../common/user.nix
  ];

  # Configs
  services = {
    flatpak.enable = true;
    cron.systemCronJobs = [
      "0 2 * * * root docker restart invidious invidious-db invidious-sig-helper"
      "0 2 * * */2 lemon ludusavi backup --force"
    ];
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}

