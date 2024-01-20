{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix
  ];
  
  # Boot
  boot = {
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        useOSProber = true;
        device = "nodev";
        gfxmodeEfi = "1920x1080";
        configurationLimit = 50;
      };
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [ "iwlwifi" "kvm-amd" ];
  };

  # Networking
  networking = {
    hostName = "silver";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [
        22 # SSH
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
      "enp10s0" = {
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

  # Users
  users = {
    users = {
      "lemon" = {
        description = "Lemon";
        home = "/home/lemon";
        hashedPassword = "$6$J7q0.RZ88OJiQRkq$mQx2d32YHf6IXqZNMSv.o/sslQMgBAGIKID2aL6tLpN6XFpXp2Fda5p1Yi78H/cXOolBPIuXEQPzxhmKp5qWc0";
        extraGroups = [ "wheel" "networkmanager" "docker" "video" "storage" "kvm" "libvirtd" ];
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

  # Packages
  environment = {
    systemPackages = with pkgs; [
      nvtop-nvidia
      # Required for the FS to complete its check and allow me to boot while on nixos-23.05
      pkgs.unstable.e2fsprogs
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
  };
  virtualisation = {
    docker = { 
      enable = true;
      enableOnBoot = true;
      enableNvidia = true;
      liveRestore = false;
      autoPrune = {
        enable = true;
        dates = "monthly";
      };
      daemon.settings = {
        hosts = [ "unix:///var/run/docker.sock" ];
      };
    };
    libvirtd.enable = true;
  };
  hardware = {
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      powerManagement.enable = true;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    bluetooth.enable = true;
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
