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
    pipewire = {
      extraConfig = {
        pipewire."92-reduce-popping" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 512;
            "default.clock.min-quantum" = 256;
            "default.clock.max-quantum" = 1024;
          };
        };
      };
    };
  };
}

