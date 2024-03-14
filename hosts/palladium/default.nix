{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/default.nix
    ../../modules/nixos/ssh.nix
  ];
  
  boot = {
    loader = {
      systemd-boot.enable = false;
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      "cgroup_enable=cpuset"
      "cgroup_enable=memory"
      "cgroup_memory=1"
    ];
    kernelPackages = pkgs.linuxPackages_rpi4;
  };

  networking = {
    hostName = "palladium";
    firewall = {
      allowedTCPPorts = [
        53 # Pi-hole
        80 443 # Web traffic
        2375 2377 4789 7946 # Docker socket & Swarm
        #9001 # Portainer
      ];
      allowedUDPPorts = [
        4789 7946 # Docker Swarm
      ];
      allowedTCPPortRanges = [
        { from = 40000; to = 44000; } # Docker containers
      ];
    };
    interfaces = {
      "end0" = {
        ipv4.addresses = [{
          address = "192.168.1.178";
          prefixLength = 24;
        }];
        useDHCP = false;
      };
    };
    enableIPv6 = false;
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" ];
  };

  users = {
    groups = {
      "gpio" = { };
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
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3A5SuYn6X5rutaWKMHuxs6w7nRbbPCKZDLLGap7R1s root@palladium" ];
      };
      "nixos" = {
        uid = 1100;
        description = "NixOS";
        home = "/home/nixos";
        hashedPassword = "$6$cNJ6ms0MkyhMejF8$YO0mSA8O2D1itNJTliQ/fnXnlonGH.nWqa76u.Wj4LhbTJdrx2rwA2QhJ1rAHdLS8CFpEfOvTD8DLyGoHD8tz0";
        extraGroups = [
          "wheel" "video" "networkmanager" "storage" "docker" "gpio"
          "docker_management" "borg_management"
        ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxtuyEOkf98MkoLPKvjBxIVIC4IrsZ5IKFoxQBxpUGe nixos@palladium"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHteP0JhNBJOlom+X8PY8s0FXPdUY4VcV6PgPPzXIKi lemon@silver"
        ];
      };
      "monitor" = {
        uid = 1101;
        description = "Monitor";
        home = "/home/monitor";
        hashedPassword = "$6$4LFq7jjaZKFiMUXn$tyu9JPZ3Skpg/HmjxaNk0jV6xO6T86iy6zjTGHAUp1PYu3Lv4JGSiaGzKRkGI4G7UT66Rg0nQ/eggMdplgqrV0";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjoPX71x6n22+CfUk2skqBfT5cNFqrXLVCwcM8bpKwS root@palladium" ];
      };
      "docker" = {
        uid = 1102;
        description = "Docker";
        home = "/home/docker";
        hashedPassword = "!";
        extraGroups = [ "docker_management" ];
        isNormalUser = true;
      };
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

  environment = {
    systemPackages = with pkgs; [
      libraspberrypi raspberrypi-eeprom
    ];
  };

  services = {
    borgbackup.jobs = {
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
        startAt = "weekly";
      };
    };
    udev.extraRules = ''
      SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio", MODE="0660"
      SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio  /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
      SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add",RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
    '';
    logrotate = {
      enable = true;
      settings = {
        "/home/docker/Containers/Networking/Traefik/logs/access.log" = {
          frequency = "daily";
          rotate = 7;
        };
      };
    };
    create_ap = {
      enable = true;
      settings = {
        INTERNET_IFACE = "end0";
        WIFI_IFACE = "wlan0";
        SSID = "Unknown Network";
        PASSPHRASE = "kXP3@%p!k%N7KL!4#26Z3";
        HIDDEN = 1;
        IEEE80211AC = 1;
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
        hosts = [ "unix:///var/run/docker.sock" "tcp://0.0.0.0:2375" ];
      };
    };
  };
  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
    enableRedistributableFirmware = true;
  };

  # Drives
  # 32 GB SD (Root)

  fileSystems = {
    # 16 GB Sandisk (Home)
    "/home" = {
      device = "/dev/disk/by-uuid/fc95e5c7-b812-437e-93ac-64205074f1fb";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  system.stateVersion = "23.05";
}
