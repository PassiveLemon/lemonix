{ ... }: {
  imports = [
    ../common/user.nix
  ];

  # Configs
  services = {
    flatpak.enable = true;
    cron.systemCronJobs = [
      "0 2 * * */2 lemon ludusavi backup --force"
    ];
  };
}

