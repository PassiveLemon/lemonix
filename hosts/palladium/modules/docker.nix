{ inputs, pkgs, config, lib, ... }: {
  networking = {
    firewall = {
      allowedTCPPorts = [
        53 # DNS
        #80 443 # Web traffic
        #2377 4789 7946 # Docker socket & Swarm
        #9001 # Portainer
      ];
      #allowedUDPPorts = [
      #  #4789 7946 # Docker Swarm
      #];
      #allowedTCPPortRanges = [
      #  #{ from = 40000; to = 44000; } # Docker containers
      #];
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
        home = "/home/docker";
        hashedPassword = "!";
        extraGroups = [ "docker_management" ];
        isNormalUser = true;
      };
    };
  };

  services = {
    logrotate = {
      enable = true;
      settings = {
        "/home/docker/Containers/Networking/Traefik/logs/access.log" = {
          frequency = "daily";
          rotate = 7;
        };
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

  systemd = {
    tmpfiles.rules = [
      "Z /home/docker 770 docker docker_management - -"
      "Z /home/docker/Containers 770 docker docker_management - -"

      "z /home/docker/Containers/Networking/Traefik/acme.json 600 docker docker_management - -"
    ];
  };
}
