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
      "docker_management" = {
        gid = 1200;
      };
    };
    users = {
      "docker" = {
        uid = 1102;
        description = "Docker";
        home = "/var/empty";
        hashedPassword = "!";
        extraGroups = [ "docker_management" ];
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
        hosts = [ "unix:///var/run/docker.sock" ];
      };
    };
  };

  hardware = {
    nvidia-container-toolkit.enable = true;
  };

  services = {
    cron.systemCronJobs = [
      "0 2 * * * root docker restart invidious"
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
      "Z /home/docker 770 docker docker_management - -"
      "Z /home/docker/Containers 770 docker docker_management - -"
      "Z /home/BACKUPDRIVE/Docker 770 docker docker_management - -"

      "Z /home/HDD2TBEXT4/Media 770 docker docker_management - -"
      "Z /home/HDD2TBEXT4/Media2 770 docker docker_management - -"
      "Z /home/HDD2TBEXT4/Downloads/JDownloader 770 docker docker_management - -"

      "z /home/docker/Containers/Networking/Traefik/acme.json 600 docker docker_management - -"

      "Z /home/docker/Containers/Media/Invidious/postgresdata 770 999 docker_management - -"
      "Z /home/BACKUPDRIVE/Docker/Containers/Media/BitMagnet 770 70 docker_management - -"
    ];
  };
}

