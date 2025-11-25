{ pkgs, ... }: {
  networking = {
    firewall.extraCommands = ''
      iptables -N DOCKER-USER || true
      iptables -F DOCKER-USER

      # Allow established connections
      iptables -A DOCKER-USER -i wlp9s0 -m state --state RELATED,ESTABLISHED -j ACCEPT

      # Allow from trusted IP ranges
      iptables -A DOCKER-USER -s 100.64.0.0/24 -j ACCEPT
      iptables -A DOCKER-USER -s 192.168.1.0/24 -j ACCEPT

      # Drop everything else
      iptables -A DOCKER-USER -i wlp9s0 -j DROP
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
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "-${pkgs.docker}/bin/docker compose -f /home/lemon/Documents/GitHub/lemocker/silver/docker-compose.yml up -d";
        Restart = "on-failure";
        RestartSec = 15;
      };
      startLimitBurst = 5;
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" "network-online.target" ];
      wants = [ "network-online.target" ];
    };
    tmpfiles.rules = [
      "Z /home/docker 770 docker docker-management - -"
      "Z /home/docker/Volumes 770 docker docker-management - -"
      "Z /home/lemon/Documents/GitHub/lemocker/silver 770 docker docker-management - -"

      "Z /data/HDD2TBEXT4/Media2 770 docker docker-management - -"
      "Z /data/HDD2TBEXT4/Downloads/JDownloader 770 docker docker-management - -"
    ];
  };
}

