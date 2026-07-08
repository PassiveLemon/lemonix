{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      beets rsgain
    ];
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 2049 ];
      allowedUDPPorts = [ 2049 ];
    };
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
        home = "/home/docker";
        hashedPassword = "!";
        extraGroups = [ "docker-management" ];
        isNormalUser = true;
      };
    };
  };

  services = {
    cron.systemCronJobs = [
      # As recommended in https://docs.invidious.io/installation/#highly-recommended
      "0 2 * * *  docker  docker restart invidious invidious-db invidious-companion"
      "0 3 * * 2  docker  /data/Media/Music/rsgain.sh"
      "0 3 * * 4  docker  rm -r /data/Media/Music/Soulseek/* && mkdir /data/Media/Music/Soulseek/Incomplete"
    ];
    nfs.server = {
      enable = true;
      exports = ''
        /export/data 192.168.1.10(rw,sync)
      '';
    };
  };

  fileSystems = {
    "/export/data" = {
      device = "/data";
      fsType = "none";
      options = [ "bind" ];
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

  systemd = {
    services.compose-up = {
      description = "docker compose up";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "-${pkgs.docker}/bin/docker compose -f /data/docker/lemocker/titanium/docker-compose.yml up -d";
        Restart = "on-failure";
        RestartSec = 15;
      };
      startLimitBurst = 5;
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" "network-online.target" ];
      wants = [ "network-online.target" ];
    };
    tmpfiles.rules = [
      "Z /data/docker 770 docker docker-management - -"

      "Z /data/Media 770 docker docker-management - -"
      "Z /data/Media/Comics/Manga 770 1000 docker-management - -"

      "Z /data/docker/volumes/discovery/KamiYomu 770 1000 docker-management - -"
      "z /data/docker/volumes/networking/Traefik/acme.json 600 docker docker-management - -"
      "Z /data/docker/volumes/streaming/Invidious/postgresdata 770 999 docker-management - -"
      "Z /data/docker/volumes/utility/LiveSync 770 5984 docker-management - -"
      "Z /data/docker/volumes/utility/Yamtrack/cache 770 999 docker-management - -"
    ];
  };
}

