{ config, ... }: {
  users = {
    groups = {
      "borg_management" = {
        gid = 1201;
      };
    };
    users = {
      "borg" = {
        uid = 1103;
        description = "Borg";
        home = "/home/borg";
        hashedPassword = "$6$ZfEb26naaa.Sx5XE$EuCvgHvdXN68flpvEh0hfeqSbAZUzf7Q5zGjiGXuxk8owgePS8OK477LA740Gm1iOabOBSZa4CZP3fL3JgG.I0";
        extraGroups = [ "borg_management" "docker_management" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOH57JnHLmW6Al34ksW1zb0TJq7IY9mZLN7kBiFR0dYi borg@silver"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL2l60AJF1l0HPUYcHSUfxQgSRrwEWTke0ByWJnUvrBu borg@palladium"
        ];
      };
    };
  };

  age.secrets = {
    borgBackupPass = {
      file = ../../../secrets/borgBackupPass.age;
      mode = "600";
      owner = "borg";
      group = "borg_management";
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
      repo = "ssh://borg@127.0.0.1/home/BACKUPDRIVE/BorgBackups/silver";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgBackupPass.path}";
      };
      environment.BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
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
        "/home/HDD2TBEXT4/Media/Music"
        "/home/BACKUPDRIVE/ManualBackups"
      ];
      repo = "ssh://borg@127.0.0.1/home/BACKUPDRIVE/BorgBackups/silver";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgBackupPass.path}";
      };
      environment.BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
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
        "/home/HDD2TBEXT4/Media/Music"
        "/home/BACKUPDRIVE/ManualBackups"
      ];
      repo = "ssh://u412758@u412758.your-storagebox.de:23/home/BorgBackups/silver";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borgBackupPass.path}";
      };
      environment.BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
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
      "Z /home/BACKUPDRIVE/BorgBackups 750 borg borg_management - -"
      "Z /home/BACKUPDRIVE/BorgMount 750 borg borg_management - -"
    ];
  };
}

