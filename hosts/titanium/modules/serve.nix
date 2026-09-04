{ config, lib, pkgs, ... }: {
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
  };
  systemd = {
    user.services = let
      inherit (lib) listToAttrs map mergeAttrsList;
      nixosConfigs = [
        "aluminum"
        "silver"
        "titanium"
      ];
      homeConfigs = [
        "lemon@aluminum"
        "lemon@silver"
      ];
      flake = "--flake /data/lemonix";
      mkNixOSJob = host: {
        description = "build-${host}";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/data/lemonix";
          ExecStart = "${pkgs.nixos-rebuild-ng}/bin/nixos-rebuild build ${flake}#${host}";
        };
        after = [ "flake-update.service" ];
        requires = [ "flake-update.service" ];
      };
      mkHomeJob = userhost: {
        description = "build-${userhost}";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/data/lemonix";
          ExecStart = "${pkgs.home-manager.home-manager}/bin/home-manager build ${flake}#${userhost}";
        };
        path = [ pkgs.nix ];
        after = [ "flake-update.service" ];
        requires = [ "flake-update.service" ];
      };
      mkJobs = mkJob: configs:
        listToAttrs (map (name: {
          name = "build-${name}";
          value = mkJob name;
        }) configs);
    in mergeAttrsList [
      (mkJobs mkNixOSJob nixosConfigs)
      (mkJobs mkHomeJob homeConfigs)
      {
        "flake-update" = {
          description = "flake-update";
          serviceConfig = {
            Type = "oneshot";
            WorkingDirectory = "/data/lemonix";
            ExecStart = "${pkgs.nix}/bin/nix flake update ${flake}";
          };
          path = [ pkgs.git ];
          wants = map (build: "build-" + build + ".service") (nixosConfigs ++ homeConfigs);
        };
      }
    ];
    timers."flake-update" = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "04:00";
    };
  };
}

