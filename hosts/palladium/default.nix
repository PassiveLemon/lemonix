{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix
  ];
  
  # Boot
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

  # Networking
  networking = {
    hostName = "palladium";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [
        22 # SSH
        53 # Pi-hole
        80 443 # Web traffic
        2375 #2377 # Docker socket & Swarm
        #7946 # Swarm container discovery
        #9001 # Portainer
      ];
      #allowedUDPPorts = [
        #4789 # Swarm overlay network
        #7946 # Swarm container discovery
      #];
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

  # Users
  users = {
    groups = {
      "gpio" = { };
    };
    users = {
      "nixos" = {
        description = "NixOS";
        home = "/home/nixos";
        hashedPassword = "$6$cNJ6ms0MkyhMejF8$YO0mSA8O2D1itNJTliQ/fnXnlonGH.nWqa76u.Wj4LhbTJdrx2rwA2QhJ1rAHdLS8CFpEfOvTD8DLyGoHD8tz0";
        extraGroups = [ "wheel" "networkmanager" "docker" "video" "storage" "gpio" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxtuyEOkf98MkoLPKvjBxIVIC4IrsZ5IKFoxQBxpUGe nixos@palladium" ];
      };
      "monitor" = {
        description = "Monitor";
        home = "/home/monitor";
        hashedPassword = "$6$4LFq7jjaZKFiMUXn$tyu9JPZ3Skpg/HmjxaNk0jV6xO6T86iy6zjTGHAUp1PYu3Lv4JGSiaGzKRkGI4G7UT66Rg0nQ/eggMdplgqrV0";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjoPX71x6n22+CfUk2skqBfT5cNFqrXLVCwcM8bpKwS root@palladium" ];
      };
    };
  };

  # Packages
  environment = {
    systemPackages = with pkgs; [
      libraspberrypi raspberrypi-eeprom
    ];
  };

  # Configs
  services = {
    openssh = {
      enable = true;
      extraConfig = ''
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AllowTcpForwarding yes
        AuthenticationMethods publickey
        ChallengeResponseAuthentication no
        KbdInteractiveAuthentication no
        PasswordAuthentication no
        PermitEmptyPasswords no
        PermitRootLogin no
        X11Forwarding no
      '';
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
  };
  virtualisation = {
    docker = { 
      enable = true;
      enableOnBoot = true;
      liveRestore = false;
      autoPrune = {
        enable = true;
        dates = "monthly";
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
