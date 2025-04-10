{ pkgs, ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [
        54384 # LiveSync
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      lazydocker
    ];
  };

  users = {
    groups = {
      "docker-management" = {
        gid = 1202;
      };
    };
    users = {
      "docker" = {
        uid = 1102;
        description = "Docker";
        home = "/var/empty";
        hashedPassword = "!";
        extraGroups = [ "docker-management" ];
        isNormalUser = true;
      };
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      liveRestore = false;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      daemon.settings = {
        hosts = [
          "unix:///var/run/docker.sock"
          "tcp://localhost:2375"
        ];
      };
    };
  };

  hardware = {
    nvidia-container-toolkit.enable = true;
  };

  services = {
    cron.systemCronJobs = [
      "0 2 * * * root docker restart invidious invidious-db invidious-sig-helper"
    ];
  };

  systemd = {
    services.stack-up = {
      description = "Docker stack upper";
      serviceConfig = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
        ExecStart = "${pkgs.docker}/bin/docker compose -f /home/lemon/Documents/GitHub/lemocker/silver/docker-compose.yaml up -d";
        ExecStartPost = "${pkgs.coreutils}/bin/sleep 30";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" ];
    };
    tmpfiles.rules = [
      "Z /home/docker 770 docker docker-management - -"
      "Z /home/docker/Volumes 770 docker docker-management - -"
      "Z /home/BACKUPDRIVE/Docker 770 docker docker-management - -"

      "Z /home/HDD2TBEXT4/Media 770 docker docker-management - -"
      "Z /home/HDD2TBEXT4/Media2 770 docker docker-management - -"
      "Z /home/HDD2TBEXT4/Downloads/JDownloader 770 docker docker-management - -"

      "z /home/docker/Volumes/Networking/Traefik/acme.json 600 docker docker-management - -"

      "Z /home/docker/Volumes/Streaming/Invidious/postgresdata 770 999 docker-management - -"
      "Z /home/docker/Volumes/Utilities/Yamtrack/cache 770 999 docker-management - -"
      "Z /home/BACKUPDRIVE/Docker/Volumes/Torrenting/BitMagnet 770 70 docker-management - -"
    ];
  };
}

