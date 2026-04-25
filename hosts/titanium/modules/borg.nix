{ config, pkgs, ... }: {
  users = {
    groups = {
      "borg-management" = {
        gid = 1203;
      };
    };
    users = {
      "borg" = {
        uid = 1103;
        description = "Borg";
        home = "/home/borg";
        hashedPassword = "$6$MtSAYxY8upZRU1nk$ktFdgqil9HqxMexHEvp25f4iPYJMPXVnOugH8tRbQyMB1ILX1DLOCwL3nmcvR3RwJIgEELt.SP1LdwRNP0W4L/";
        extraGroups = [ "borg-management" "docker-management" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGt7EoDxKbFzXMXVV+RF422Tt9dBS7gKIgWMLxWncax9 borg@titanium"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCBA9bX/zAfV04lQXGPPL+f24qD+MrX7zDt+odiE0pI root@titanium"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOH57JnHLmW6Al34ksW1zb0TJq7IY9mZLN7kBiFR0dYi borg@silver"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbedW5DDGCzGpbym2f0Ex+efnyfzFfHRPAhDFY9ZI5K root@silver"
        ];
      };
    };
  };

  age.secrets = {
    borgBackupPass = {
      file = ../../../secrets/borgBackupPass.age;
      mode = "600";
      owner = "borg";
      group = "borg-management";
    };
  };

  services.borgbackup.jobs = let
    docker = (repo: {
      inherit repo;
      paths = [
        "/data/docker"
        "/data/Media/Music"
      ];
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgBackupPass.path}";
      };
      environment = {
        BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
        BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
      };
      compression = "auto,zstd";
      startAt = "daily";
      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = -1;
      };
    });
  in {
    "docker-local" = docker "ssh://borg@127.0.0.1/data/BorgBackups/titanium";
    "docker-onsite" = docker "ssh://borg@silver/data/BACKUPDRIVE/BorgBackups/titanium";
    "docker-remote" = docker "ssh://u412758@u412758.your-storagebox.de:23/home/BorgBackups/titanium";
  };

  systemd = {
    tmpfiles.rules = [
      "Z /data/BorgBackups 750 borg borg-management - -"
      "Z /data/BorgMount 750 borg borg-management - -"
    ];
    services.borgbackup-job-docker-local = {
      serviceConfig = {
        ExecStartPre = "${pkgs.docker}/bin/docker compose -f /data/docker/lemocker/titanium/docker-compose.yml stop";
        ExecStopPost = "-${pkgs.docker}/bin/docker compose -f /data/docker/lemocker/titanium/docker-compose.yml start";
      };
    };
  };
}

