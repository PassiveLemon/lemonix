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
        extraGroups = [ "wheel" "networkmanager" "docker" "video" "storage" "kvm" "libvirtd" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCG6NqaIG0ltxWYwMjCyWHg9/gfYSbqzkLhENJSVVOYtLUfmMU0VdBeStyfU+yR9Ey5L2OuGamh4LXWVq3J2WMNhvM8puSUlSP4BCSy5+ZgjFbyFbLv6k4XOQzEpNgW9wemXcwRey2Irw+9uj3JTzEyXEzhgymBC0useH2+vi38RA0Q6U41sa01YFfDPMPYeBw5ooNFQOKGCGHS8YwSOOca1hk/qaaRPseYakzTa2sfYbOJOF6QrQLh+qn8GDrWj4MZEqhSiZBbJywPl+qtPMovGWQA2YeP88KtomWQ9kiGhvIrgngg/YelpI+hrBFohEE1FyGru/xnjKN6MlbPtUzcXbyWsppCEQjvW8UMJlWRCWjg11oeVCgmn0iCVxm9+1QNMfRo/w3bIkQVdwYU+IvWcUFyY7pc4Fpvtr+Zz+Jhxv+DPDrWED262pVp23rkLzTsCatB2I5+SpvEesc0arY5dQinjm6AOGkyDCX6pNlCg9azygiPw1pAu49Z9TgWNNU= lemon@silver" ];
      };
      "monitor" = {
        description = "Monitor";
        home = "/home/monitor";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwMBh4nqwYBgpB7Pp/tE83y91C23P3eSyTFaOGPQL88QMUBJP1ZMKM3lotXPIZ+ADDUitNvLfsRTzXsCxWjhsNM1Y5Egf36aQm24ZA/h6jj9mSs/EVp7jZR72ok5gYCxtg9QfwAlEXhaIBQq/XzbAwORN23AJJR8ymSrGnmkm550XzsXbEFKg2EG49kXEWrzPKpMvcL02U7tPiSxH99aJieFXyDEFxssOU6Scv9AIU6ERxwlKYV2bVMF3RLkpJ8mkgcuOVt7i4fHFkcKERRHbx3k6RsbBN4xt/Nhu4hkE+6MTY1u8q9S3kJr5s80Gfpp7zgCjhwB4y7VpLpnQSQk1ewf/pKhNB61dvMkU4B7X1znitN+GR291XEOIAeCl4ba7ATBfmyouhQ0wpGsRvYfheyXMo7u4z43kq3mZSAKWuLNmGUv469HZ4vTKo8IZ+xBC2pHn9hlXLfeHXmVa/XwtnXpmi23xkr6TKxATYVYAsWO9A5Ll//L+EWluAhjj5jT8= monitor@silver" ];
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
