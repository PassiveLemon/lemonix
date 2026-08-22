{ config, pkgs, ... }: {
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

  services = {
    # Pub: NM3ZERLgd7ag9kcwMoQYszeBTUp+OMmUSGDN5lwWO6I=
    nix-serve = {
      enable = true;
      openFirewall = true;
      secretKeyFile = config.age.secrets.nixServeKey.path;
    };
    cron.systemCronJobs = let
      flake = "--flake /data/lemonix";
      nixos = host: "nixos-rebuild build ${flake}#${host}";
      home = userhost: "${pkgs.home-manager.home-manager}/bin/home-manager build ${flake}#${userhost}";
    in [
      "0 4 * * *  root  nix flake update ${flake} ; ${nixos "aluminum"} ; ${nixos "silver"} ; ${nixos "titanium"}"
      "0 5 * * *  lemon  ${home "lemon@aluminum"} ; ${home "lemon@silver"}"
    ];
  };
}

