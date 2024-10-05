{ inputs, pkgs, config, lib, ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [
        #53 # DNS
        #80 443 # Web traffic
        #2377 7946 # Docker socket & Swarm
        54384 # LiveSync
      ];
      # allowedUDPPorts = [
      #   #4789 7946 # Docker Swarm
      # ];
      # allowedTCPPortRanges = [
      #   #{ from = 50000; to = 56000; } # Docker containers
      # ];
      # allowedUDPPortRanges = [
      #   #{ from = 50000; to = 56000; } # Docker containers
      # ];
    };
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
      enableNvidia = true; # Keeping this enabled until they finally fix the deprecation
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

