{ config, ... }: {
  users = {
    groups = {
      "borg-management" = {
        gid = 1201;
      };
    };
    users = {
      "borg" = {
        uid = 1103;
        description = "Borg";
        home = "/home/borg";
        hashedPassword = "$6$H.OMKehp89SXUJcD$UppHgGDwiKk727vZ67YGpyqRNfwXJP6Zgx953CBqJLSbhMVQfVlqPyg5YJ7JBrUJAA5jNrTCFLNxSXqfBnz0J.";
        extraGroups = [ "borg-management" "docker-management" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL2l60AJF1l0HPUYcHSUfxQgSRrwEWTke0ByWJnUvrBu borg@palladium" ];
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
        "/home/docker"
      ];
      repo = "ssh://borg@192.168.1.177/home/BACKUPDRIVE/BorgBackups/palladium";
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
      ];
      repo = "ssh://u412758@u412758.your-storagebox.de:23/home/BorgBackups/palladium";
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
}

