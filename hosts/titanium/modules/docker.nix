{ pkgs, ... }: {
  networking = {
    firewall.extraCommands = ''
      iptables -N DOCKER-USER || true
      iptables -F DOCKER-USER

      # Allow established connections
      iptables -A DOCKER-USER -i wlp5s0 -m state --state RELATED,ESTABLISHED -j ACCEPT

      # Allow from trusted IP ranges
      iptables -A DOCKER-USER -s 100.64.0.0/24 -j ACCEPT
      iptables -A DOCKER-USER -s 192.168.1.0/24 -j ACCEPT

      # Drop everything else
      iptables -A DOCKER-USER -i wlp5s0 -j DROP
    '';
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

  services = {
    cron.systemCronJobs = [
      "0 2 * * * root docker restart invidious invidious-db invidious-companion"
      "0 3 * * 6 root /data/Media/Music/rsgain.sh"
    ];
  };

  systemd = {
    services.stack-up = {
      description = "Docker stack upper";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
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
      "Z /data/docker/lemocker/titanium 770 docker docker-management - -"

      "Z /data/Media 770 docker docker-management - -"
      "Z /data/Media/Comics/Manga 770 1000 docker-management - -"

      "Z /data/docker/Volumes/Media/KamiYomu 770 1000 docker-management - -"
      "z /data/docker/Volumes/Networking/Traefik/acme.json 600 docker docker-management - -"
      "Z /data/docker/Volumes/Streaming/Invidious/postgresdata 770 999 docker-management - -"
      "Z /data/docker/Volumes/Utilities/Yamtrack/cache 770 999 docker-management - -"
      "Z /data/docker/Volumes/Utilities/LiveSync 770 5984 docker-management - -"
    ];
  };
}

