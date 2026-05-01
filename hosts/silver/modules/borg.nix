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
        hashedPassword = "$6$ZfEb26naaa.Sx5XE$EuCvgHvdXN68flpvEh0hfeqSbAZUzf7Q5zGjiGXuxk8owgePS8OK477LA740Gm1iOabOBSZa4CZP3fL3JgG.I0";
        extraGroups = [ "borg-management" "docker-management" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOH57JnHLmW6Al34ksW1zb0TJq7IY9mZLN7kBiFR0dYi borg@silver"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbedW5DDGCzGpbym2f0Ex+efnyfzFfHRPAhDFY9ZI5K root@silver"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGt7EoDxKbFzXMXVV+RF422Tt9dBS7gKIgWMLxWncax9 borg@titanium"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCBA9bX/zAfV04lQXGPPL+f24qD+MrX7zDt+odiE0pI root@titanium"
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
    base = (paths: exclude: repo: {
      inherit paths exclude repo;
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgBackupPass.path}";
      };
      environment = {
        BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
        BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
      };
      compression = "auto,zstd";
      startAt = "*-*-* 04:00:00";
      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = -1;
      };
    });
    docker = (repo: base [
      "/home/docker"
      "/data/BACKUPDRIVE/ManualBackups"
    ] [] repo);
    lemon = (repo: base [
      "/home/lemon/Documents"
      "/home/lemon/Music"
      "/home/lemon/Pictures"
      "/home/lemon/Shared"
      "/home/lemon/Standalone"
      "/home/lemon/Videos"
      "/home/lemon/.config"
      "/home/lemon/.local/share"
    ] [
      "/home/lemon/.config/r2modmanPlus-local/*/cache"
      "/home/lemon/.local/share/Trash"
      "/home/lemon/.local/share/Steam/steamapps"
      "/home/lemon/.local/share/Steam/compatibilitytools.d"
    ] repo);
  in {
    "lemon-local" = lemon "ssh://borg@127.0.0.1/data/BACKUPDRIVE/BorgBackups/silver";
    "lemon-onsite" = lemon "ssh://borg@titanium/data/BorgBackups/silver";
    "lemon-remote" = lemon "ssh://u412758@u412758.your-storagebox.de:23/home/BorgBackups/silver";

    "docker-local" = docker "ssh://borg@127.0.0.1/data/BACKUPDRIVE/BorgBackups/silver";
    "docker-onsite" = docker "ssh://borg@titanium/data/BorgBackups/silver";
    "docker-remote" = docker "ssh://u412758@u412758.your-storagebox.de:23/home/BorgBackups/silver";
  };

  systemd = {
    tmpfiles.rules = [
      "Z /data/BACKUPDRIVE/BorgBackups 750 borg borg-management - -"
      "Z /data/BACKUPDRIVE/BorgMount 750 borg borg-management - -"
    ];
    services.borgbackup-job-docker-onsite = {
      serviceConfig = {
        ExecStartPre = "${pkgs.docker}/bin/docker compose -f /home/lemon/Documents/GitHub/lemocker/silver/docker-compose.yml stop";
        ExecStopPost = "-${pkgs.docker}/bin/docker compose -f /home/lemon/Documents/GitHub/lemocker/silver/docker-compose.yml start";
      };
    };
  };
}

