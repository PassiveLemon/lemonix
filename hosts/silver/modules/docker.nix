{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      jellyfin-ffmpeg
    ];
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
        extraGroups = [
          "video" "render"
          "docker-management"
        ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7D6y618TGPHBbKGP0YJJxjdFLSaJ4aBdsEIs6z0Fl docker@silver"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ7D6y618TGPHBbKGP0YJJxjdFLSaJ4aBdsEIs6z0Fl docker@titanium"
        ];
      };
    };
  };

  boot.supportedFilesystems = [ "nfs" ];

  fileSystems = {
    "/mnt/titanium" = {
      device = "192.168.1.11:/export/data";
      fsType = "nfs4";
      options = [ "noauto" "x-systemd.automount" "x-systemd.idle-timeout=600" ];
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
        ];
      };
    };
  };

  hardware = {
    nvidia-container-toolkit.enable = true;
  };

  systemd = {
    services.compose-up = {
      description = "docker compose up";
      serviceConfig = {
        Type = "oneshot";
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
      
      "Z /home/lemon/Documents/GitHub/lemocker/silver 770 docker docker-management - -"

      "Z /data/NVMESABRENT/Media 770 docker docker-management - -"
    ];
  };
}

