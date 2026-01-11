{ config, ... }: {
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

  services.borgbackup.jobs = {
    "lemon-local" = {
      paths = [
        "/home/lemon/Documents"
        "/home/lemon/Music"
        "/home/lemon/Pictures"
        "/home/lemon/Shared"
        "/home/lemon/Standalone"
        "/home/lemon/Videos"
        "/home/lemon/.config"
        "/home/lemon/.local/share"
      ];
      exclude = [
        "/home/lemon/.config/r2modmanPlus-local/*/cache"
        "/home/lemon/.local/share/Trash"
        "/home/lemon/.local/share/Steam/steamapps"
        "/home/lemon/.local/share/Steam/compatibilitytools.d"
      ];
      repo = "ssh://borg@127.0.0.1/data/BACKUPDRIVE/BorgBackups/silver";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgBackupPass.path}";
      };
      environment = {
        BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
        BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
      };
      failOnWarnings = false;
      compression = "auto,zstd";
      startAt = "daily";
      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = -1;
      };
    };
    "lemon-onsite" = {
      paths = [
        "/home/lemon/Documents"
        "/home/lemon/Music"
        "/home/lemon/Pictures"
        "/home/lemon/Shared"
        "/home/lemon/Standalone"
        "/home/lemon/Videos"
        "/home/lemon/.config"
        "/home/lemon/.local/share"
      ];
      exclude = [
        "/home/lemon/.config/r2modmanPlus-local/*/cache"
        "/home/lemon/.local/share/Trash"
        "/home/lemon/.local/share/Steam/steamapps"
        "/home/lemon/.local/share/Steam/compatibilitytools.d"
      ];
      repo = "ssh://borg@titanium/data/BorgBackups/silver";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgBackupPass.path}";
      };
      environment.BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
      failOnWarnings = false;
      compression = "auto,zstd";
      startAt = "daily";
      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = -1;
      };
    };
    "lemon-remote" = {
      paths = [
        "/home/lemon/Documents"
        "/home/lemon/Music"
        "/home/lemon/Pictures"
        "/home/lemon/Shared"
        "/home/lemon/Standalone"
        "/home/lemon/Videos"
        "/home/lemon/.config"
        "/home/lemon/.local/share"
      ];
      exclude = [
        "/home/lemon/.config/r2modmanPlus-local/*/cache"
        "/home/lemon/.local/share/Trash"
        "/home/lemon/.local/share/Steam/steamapps"
        "/home/lemon/.local/share/Steam/compatibilitytools.d"
      ];
      repo = "ssh://u412758@u412758.your-storagebox.de:23/home/BorgBackups/silver";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgBackupPass.path}";
      };
      environment.BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
      failOnWarnings = false;
      compression = "auto,zstd";
      startAt = "daily";
      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = -1;
      };
    };

    "docker-local" = {
      paths = [
        "/home/docker"
        "/data/BACKUPDRIVE/ManualBackups"
      ];
      repo = "ssh://borg@127.0.0.1/data/BACKUPDRIVE/BorgBackups/silver";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgBackupPass.path}";
      };
      environment = {
        BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
        BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
      };
      failOnWarnings = false;
      compression = "auto,zstd";
      startAt = "daily";
      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = -1;
      };
    };
    "docker-onsite" = {
      paths = [
        "/home/docker"
        "/data/BACKUPDRIVE/ManualBackups"
      ];
      repo = "ssh://borg@titanium/data/BorgBackups/silver";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgBackupPass.path}";
      };
      environment.BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
      failOnWarnings = false;
      compression = "auto,zstd";
      startAt = "daily";
      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = -1;
      };
    };
    "docker-remote" = {
      paths = [
        "/home/docker"
        "/data/BACKUPDRIVE/ManualBackups"
      ];
      repo = "ssh://u412758@u412758.your-storagebox.de:23/home/BorgBackups/silver";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgBackupPass.path}";
      };
      environment.BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
      failOnWarnings = false;
      compression = "auto,zstd";
      startAt = "daily";
      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = -1;
      };
    };
  };

  systemd = {
    tmpfiles.rules = [
      "Z /data/BACKUPDRIVE/BorgBackups 750 borg borg-management - -"
      "Z /data/BACKUPDRIVE/BorgMount 750 borg borg-management - -"
    ];
  };
}

