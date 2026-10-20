{ outputs, config, lib, pkgs, ... }: {
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
      inherit (lib) concatStringsSep attrNames;
      nixosConfigs = concatStringsSep " " (attrNames outputs.nixosConfigurations);
      homeConfigs = concatStringsSep " " (attrNames outputs.homeConfigurations);
    in {
      "nightly-flake-update" = {
        description = "nightly-flake-update";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/data/lemonix";
          ExecStart = "${./flake-update.sh} '${nixosConfigs}' '${homeConfigs}'";
        };
        path = with pkgs; [ bash git nix nixos-rebuild-ng home-manager.home-manager ];
        startAt = "04:00";
      };
    };
  };
}

