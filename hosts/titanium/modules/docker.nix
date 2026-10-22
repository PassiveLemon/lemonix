{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    beets rsgain yt-dlp
    lemonake.outsource jellyfin-ffmpeg
  ];

  networking.firewall = {
    # NFS
    allowedTCPPorts = [ 2049 ];
    allowedUDPPorts = [ 2049 ];
  };

  users = {
    groups."docker-management".gid = 1202;
    users."docker" = {
      uid = 1102;
      home = "/home/docker";
      hashedPassword = "!";
      extraGroups = [ "docker-management" ];
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7D6y618TGPHBbKGP0YJJxjdFLSaJ4aBdsEIs6z0Fl docker@titanium"
      ];
    };
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /export/data 192.168.1.10(rw,sync)
    '';
  };

  fileSystems."/export/data" = {
    device = "/data";
    fsType = "none";
    options = [ "bind" ];
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    liveRestore = false;
    autoPrune = {
      enable = true;
      dates = "Mon 02:00";
      flags = [ "--all" "--filter=until=7d" ];
      allVolumes.enable = true; # Everything is stored through a host mount
    };
  };

  systemd = {
    user.services = {
      "docker-deploy" = {
        description = "docker-deploy";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/data/docker/lemocker";
          ExecStart = "-${pkgs.docker}/bin/docker compose up -d";
          RemainAfterExit = true;
        };
        wantedBy = [ "multi-user.target" ];
        after = [ "docker.service" ];
        wants = [ "docker.service" ];
      };
      "restart-invidious" = {
        # As recommended in https://docs.invidious.io/installation/#highly-recommended
        description = "restart-invidious";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.docker}/bin/docker restart invidious invidious-db invidious-companion";
        };
        startAt = "03:00";
      };
      "rsgain" = {
        description = "rsgain";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/data/Media/Music/";
          ExecStart = "/data/Media/Music/rsgain.sh";
        };
        path = with pkgs; [ bash rsgain ];
        startAt = "Mon 03:00";
      };
      "cleanup-soulseek" = {
        description = "cleanup-soulseek";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/data/Media/Music/Soulseek/";
          ExecStart = "rm ./*";
          ExecStartPost = "mkdir /data/Media/Music/Soulseek/Incomplete";
        };
        startAt = "Mon 02:00";
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

