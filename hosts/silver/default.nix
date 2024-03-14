{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/default.nix
    ../../modules/nixos/swap.nix
    ../../modules/nixos/ssh.nix
  ];
  
  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [ "iwlwifi" "kvm-amd" ];
  };

  networking = {
    hostName = "silver";
    firewall = {
      allowedTCPPorts = [
        2375 2377 7946 # Docker socket & Swarm
        5500 # HTML Webserver for testing
        #9001 # Portainer
      ];
      allowedUDPPorts = [
        4789 7946 # Docker Swarm
      ];
      allowedTCPPortRanges = [
        { from = 50000; to = 55000; } # Docker containers
      ];
    };
    interfaces = {
      "enp7s0" = {
        ipv4.addresses = [{
          address = "192.168.1.177";
          prefixLength = 24;
        }];
        useDHCP = false;
      };
    };
    enableIPv6 = false;
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.178" "1.1.1.1" ];
  };

  users = {
    groups = {
      "docker_management" = {
        gid = 1200;
      };
      "borg_management" = {
        gid = 1201;
      };
    };
    users = {
      "root" = {
        home = "/root";
        hashedPassword = "!";
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElxtrdcStwa3bBpK9WxyyQq/x27oqhDbVlOPoLkbfRH root@silver" ];
      };
      "lemon" = {
        uid = 1100;
        description = "Lemon";
        home = "/home/lemon";
        hashedPassword = "$6$J7q0.RZ88OJiQRkq$mQx2d32YHf6IXqZNMSv.o/sslQMgBAGIKID2aL6tLpN6XFpXp2Fda5p1Yi78H/cXOolBPIuXEQPzxhmKp5qWc0";
        extraGroups = [
          "wheel" "video" "audio" "networkmanager" "storage" "docker" "kvm" "libvirtd" 
          "docker_management" "borg_management"
        ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHteP0JhNBJOlom+X8PY8s0FXPdUY4VcV6PgPPzXIKi lemon@silver" ];
      };
      "monitor" = {
        uid = 1101;
        description = "Monitor";
        home = "/home/monitor";
        hashedPassword = "$6$0XNvp3iEh8YJqrVr$43U1A.yN9kdw4CZJ9YpJYuEzyUzLYbOWIIDpK54bJdlhaXMl5P0Y3eicO/MEZSKBGQpTfzlFDVQFesIRKHLXN0";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7MCTB+V/YSqbRZIWlAsh5uPAfBToG3Pg8JsYgnIKg2 monitor@silver" ];
      };
      "docker" = {
        uid = 1102;
        description = "Docker";
        home = "/var/empty";
        hashedPassword = "!";
        extraGroups = [ "docker_management" ];
        isNormalUser = true;
      };
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

  environment = {
    systemPackages = with pkgs; [
      nvtop-nvidia
    ];
  };

  services.borgbackup.jobs = {
    "lemon-silver" = {
      paths = [
        "/home/lemon/Documents"
        "/home/lemon/Pictures"
        "/home/lemon/Videos"
        "/home/lemon/Music"
        "/home/lemon/.local/share/gdlauncher_carbon/data/instances"
      ];
      repo = "ssh://borg@127.0.0.1/home/BACKUPDRIVE/BorgBackups";
      encryption = {
        mode = "repokey";
        passCommand = "cat /home/borg/borgbackup";
      };
      environment.BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
      compression = "auto,zstd";
      startAt = "daily";
    };
    "docker-silver" = {
      paths = [
        "/home/docker"
      ];
      repo = "ssh://borg@127.0.0.1/home/BACKUPDRIVE/BorgBackups";
      encryption = {
        mode = "repokey";
        passCommand = "cat /home/borg/borgbackup";
      };
      environment.BORG_RSH = "ssh -i /home/borg/.ssh/id_ed25519";
      compression = "auto,zstd";
      startAt = "weekly";
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
    libvirtd.enable = true;
  };
  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      powerManagement.enable = true;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  # Drives
  # 500 GB Crucial (Root)
  
  fileSystems = {
    # 1 TB Sabrent (Home)
    "/home" = {
      device = "/dev/disk/by-uuid/30266ca4-5926-430a-83f5-403c30092cf5";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    # 2 TB Seagate
    "/home/HDD2TBEXT4" = {
      device = "/dev/disk/by-uuid/c532ca53-130a-46c6-9e06-3aee4fd8b6e2";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    # 1 TB Toshiba
    "/home/BACKUPDRIVE" = {
      device = "/dev/disk/by-uuid/76946991-d872-4936-82f2-298225ea010b";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  system.stateVersion = "23.05";
}

