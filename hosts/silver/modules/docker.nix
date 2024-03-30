{ inputs, pkgs, config, lib, ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [
        2377 7946 # Docker socket & Swarm
      ];
      allowedUDPPorts = [
        4789 7946 # Docker Swarm
      ];
      allowedTCPPortRanges = [
        { from = 50000; to = 55000; } # Docker containers
      ];
      allowedUDPPortRanges = [
        { from = 50000; to = 55000; } # Docker containers
      ];
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
      enableOnBoot = true;
      enableNvidia = true;
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

  systemd = {
    tmpfiles.rules = [
      "Z /home/docker 770 docker docker_management - -"
      "Z /home/docker/Containers 770 docker docker_management - -"
      "Z /home/BACKUPDRIVE/Docker 770 docker docker_management - -"

      "Z /home/docker/Containers/Media/Invidious 777 docker docker_management - -"

      "Z /home/HDD2TBEXT4/Media 770 docker docker_management - -"
      "Z /home/HDD2TBEXT4/Media2 770 docker docker_management - -"
      "Z /home/HDD2TBEXT4/Downloads/JDownloader 770 docker docker_management - -"
      "Z /home/HDD2TBEXT4/Downloads/Torrent 770 docker docker_management - -"
      "Z /home/HDD2TBEXT4/Downloads/Incomplete/Torrent 770 docker docker_management - -"
      "Z /home/HDD2TBEXT4/Downloads/Incomplete/Soulseek 770 docker docker_management - -"
    ];
  };
}
