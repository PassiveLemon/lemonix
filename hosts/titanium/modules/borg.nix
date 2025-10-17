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
        hashedPassword = "xxxxxxxxxxxxxx";
        extraGroups = [ "borg-management" "docker-management" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "xxxxxxxxxxxxx"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOH57JnHLmW6Al34ksW1zb0TJq7IY9mZLN7kBiFR0dYi borg@silver"
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
    "docker-local" = {
      paths = [
        "/data/docker"
        "/data/Media/Music"
      ];
      repo = "ssh://borg@127.0.0.1/data/BorgBackups/titanium";
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
        "/data/docker"
        "/data/Media/Music"
      ];
      repo = "ssh://u412758@u412758.your-storagebox.de:23/home/BorgBackups/titanium";
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
      "Z /data/BorgBackups 750 borg borg-management - -"
      "Z /data/BorgMount 750 borg borg-management - -"
    ];
  };
}

