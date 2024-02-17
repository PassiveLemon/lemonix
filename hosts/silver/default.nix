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
        #2375 2377 # Docker socket & Swarm
        5500 # HTML Webserver for testing
        #7946 # Swarm container discovery
        #9001 # Portainer
      ];
      #allowedUDPPorts = [
        #4789 # Swarm overlay network
        #7946 # Swarm container discovery
      #];
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
    users = {
      "lemon" = {
        description = "Lemon";
        home = "/home/lemon";
        hashedPassword = "$6$J7q0.RZ88OJiQRkq$mQx2d32YHf6IXqZNMSv.o/sslQMgBAGIKID2aL6tLpN6XFpXp2Fda5p1Yi78H/cXOolBPIuXEQPzxhmKp5qWc0";
        extraGroups = [ "wheel" "video" "audio" "networkmanager" "storage" "docker" "kvm" "libvirtd" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHteP0JhNBJOlom+X8PY8s0FXPdUY4VcV6PgPPzXIKi lemon@silver" ];
      };
      "monitor" = {
        description = "Monitor";
        home = "/home/monitor";
        hashedPassword = "$6$0XNvp3iEh8YJqrVr$43U1A.yN9kdw4CZJ9YpJYuEzyUzLYbOWIIDpK54bJdlhaXMl5P0Y3eicO/MEZSKBGQpTfzlFDVQFesIRKHLXN0";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7MCTB+V/YSqbRZIWlAsh5uPAfBToG3Pg8JsYgnIKg2 monitor@silver" ];
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      nvtop-nvidia
    ];
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

