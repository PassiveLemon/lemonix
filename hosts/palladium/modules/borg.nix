{ inputs, pkgs, config, lib, ... }: {
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
        hashedPassword = "$6$H.OMKehp89SXUJcD$UppHgGDwiKk727vZ67YGpyqRNfwXJP6Zgx953CBqJLSbhMVQfVlqPyg5YJ7JBrUJAA5jNrTCFLNxSXqfBnz0J.";
        extraGroups = [ "borg_management" "docker_management" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL2l60AJF1l0HPUYcHSUfxQgSRrwEWTke0ByWJnUvrBu borg@palladium" ];
      };
    };
  };

  services.borgbackup.jobs = {
    "nixos-palladium" = {
      paths = [
        "/home/docker"
      ];
      repo = "ssh://borg@192.168.1.177/home/BACKUPDRIVE/BorgBackups";
      encryption = {
        mode = "repokey";
        passCommand = "cat /home/borg/borgbackup";
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
