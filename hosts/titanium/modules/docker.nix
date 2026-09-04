{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      beets rsgain
      lemonake.outsource jellyfin-ffmpeg
    ];
  };

  networking = {
    firewall = {
      # NFS
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
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7D6y618TGPHBbKGP0YJJxjdFLSaJ4aBdsEIs6z0Fl docker@titanium"
        ];
      };
    };
  };

  services = {
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
        dates = "Mon 02:00";
        flags = [ "--all" ];
        allVolumes.enable = true; # Everything is stored through a host mount
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
    services = {
      "cleanup-soulseek" = {
        description = "cleanup-soulseek";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/data/Media/Music/Soulseek/";
          ExecStart = "rm ./*";
          ExecStartPost = "mkdir /data/Media/Music/Soulseek/Incomplete";
        };
      };
      "restart-invidious" = {
        # As recommended in https://docs.invidious.io/installation/#highly-recommended
        description = "restart-invidious";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.docker}/bin/docker restart invidious invidious-db invidious-companion";
        };
      };
      "rsgain" = {
        description = "rsgain";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/data/Media/Music/";
          ExecStart = "/data/Media/Music/rsgain.sh";
        };
        path = with pkgs; [ bash rsgain ];
      };
    };
    user.services = {
      "docker-deploy" = {
        description = "docker-deploy";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/data/docker/lemocker";
          ExecStart = "-${pkgs.docker}/bin/docker compose up -d";
          Restart = "on-failure";
          RestartSec = 15;
        };
        startLimitBurst = 5;
        wantedBy = [ "multi-user.target" ];
        after = [ "docker.service" "network-online.target" ];
        wants = [ "network-online.target" ];
      };
    };
    timers = {
      "cleanup-soulseek" = {
        wantedBy = [ "timers.target" ];
        timerConfig.OnCalendar = "Mon 02:00";
      };
      "restart-invidious" = {
        wantedBy = [ "timers.target" ];
        timerConfig.OnCalendar = "03:00";
      };
      "rsgain" = {
        wantedBy = [ "timers.target" ];
        timerConfig.OnCalendar = "Mon 03:00";
      };
    };
    tmpfiles.rules = [
      "Z /data/docker 770 docker docker-management - -"
      "Z /data/docker/lemocker/titanium/streaming/outsource 600 docker docker-management - -"
      "z /data/docker/lemocker/titanium/streaming/outsource 700 docker docker-management - -"

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

