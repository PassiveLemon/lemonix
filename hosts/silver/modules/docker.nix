{ inputs, pkgs, config, lib, ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [
        2375 2377 7946 # Docker socket & Swarm
        #9001 # Portainer
      ];
      allowedUDPPorts = [
        4789 7946 # Docker Swarm
      ];
      allowedTCPPortRanges = [
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
      "z /home/docker 750 docker docker_management - -"
      "z /home/docker/Containers 750 docker docker_management - -"
      "z /home/BACKUPDRIVE/Docker 750 docker docker_management - -"

      "Z /home/HDD2TBEXT4/Media 750 docker docker_management - -"
      "Z /home/HDD2TBEXT4/Media2 750 docker docker_management - -"
      "Z /home/HDD2TBEXT4/Downloads/Torrent 750 docker docker_management - -"
    ];
  };
}
