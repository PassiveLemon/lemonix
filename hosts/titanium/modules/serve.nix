{ config, ... }: {
  users = {
    groups = {
      "nix-serve" = {
        gid = 1204;
      };
    };
    users = {
      "nix-serve" = {
        uid = 1104;
        description = "Nix-serve";
        home = "/var/empty";
        hashedPassword = "!";
        isNormalUser = true;
      };
    };
  };

  age.secrets = {
    nixServeKey = {
      file = ../../../secrets/nixServeKey.age;
      mode = "600";
      owner = "nix-serve";
      group = "nix-serve";
    };
  };

  # binarycache.passivelemon.com:NM3ZERLgd7ag9kcwMoQYszeBTUp+OMmUSGDN5lwWO6I=
  services.nix-serve = {
    enable = true;
    openFirewall = true;
    secretKeyFile = config.age.secrets.nixServeKey.path;
  };

  services = {
    cron.systemCronJobs = [
      "0 4 * * *  root  nix flake update --flake /data/lemonix ; nixos-rebuild build --flake /data/lemonix#silver ; nixos-rebuild build --flake /data/lemonix#aluminum"
    ];
  };
}

