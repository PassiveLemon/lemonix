{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/system.nix
  ];

  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
    };
    kernelModules = [ "iwlwifi" "kvm-amd" ];
    # https://github.com/NixOS/nixpkgs/issues/412299
    kernelPackages = pkgs.linuxPackages_6_14;
  };

  networking = {
    hostName = "silver";
    # firewall = {
    #   allowedTCPPorts = [
    #     5500 # HTML Webserver for testing
    #   ];
    # };
    # interfaces = {
    #   "enp7s0" = {
    #     ipv4.addresses = [{
    #       address = "192.168.1.177";
    #       prefixLength = 24;
    #     }];
    #     useDHCP = false;
    #   };
    # };
    enableIPv6 = false;
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
  };

  users = {
    users = {
      "root" = {
        home = "/root";
        hashedPassword = "!";
        # The first key is just the users public key for easy reference.
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbedW5DDGCzGpbym2f0Ex+efnyfzFfHRPAhDFY9ZI5K root@silver" ];
      };
      "lemon" = {
        uid = 1100;
        description = "Lemon";
        home = "/home/lemon";
        hashedPassword = "$6$J7q0.RZ88OJiQRkq$mQx2d32YHf6IXqZNMSv.o/sslQMgBAGIKID2aL6tLpN6XFpXp2Fda5p1Yi78H/cXOolBPIuXEQPzxhmKp5qWc0";
        extraGroups = [
          "wheel" "video" "audio" "input" "networkmanager" "storage"
          "docker" "kvm" "libvirtd"
          "docker-management" "borg-management"
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
    };
  };

  environment = {
    systemPackages = with pkgs; [
      nvtopPackages.nvidia
    ];
  };

  age.secrets = {
    tailscaleAuthKey = {
      file = ../../secrets/tailscaleAuthKey.age;
      mode = "600";
      owner = "root";
      group = "root";
    };
  };

  services = {
    tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscaleAuthKey.path;
      extraUpFlags = [
        "--accept-routes"
      ];
    };
    # create_ap = {
    #   enable = true;
    #   settings = {
    #     INTERNET_IFACE = "enp7s0";
    #     WIFI_IFACE = "wlp6s0";
    #     SSID = "Unknown Network";
    #     PASSPHRASE = "kXP3@%p!k%N7KL!4#26Z3";
    #     IEEE80211N = 1;
    #     IEEE80211AC = 1;
    #     HT_CAPAB = "[HT40+][SHORT-GI-40][MAX-AMSDU-7935][TX-STBC][RX-STBC2][LDPC][DSSS_CCK-40]";
    #     VHT_CAPAB = "[SHORT-GI-160][MAX-MPDU-11454][TX-STBC][RX-STBC-2][LDPC]";
    #     FREQ_BAND = 5;
    #     HIDDEN = 1;
    #     COUNTRY = "US";
    #     ISOLATE_CLIENTS = 1;
    #   };
    # };
  };

  virtualisation = {
    libvirtd.enable = true;
  };

  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      open = true;
      modesetting.enable = true;
      powerManagement.enable = true;
    };
  };

  nixpkgs = {
    config.cudaSupport = true;
  };

  nix = {
    settings = {
      cores = 4;
      max-jobs = 2;
    };
  };

  # Drives
  # 500 GB Crucial P3 (Root)

  fileSystems = {
    # 2 TB Crucial T500 (Home)
    "/home" = {
      device = "/dev/disk/by-uuid/ceec28f7-95b7-4b92-9e43-826e70903e5d";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    # 2 TB Seagate Barracuda
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

  system.stateVersion = "23.05"; # Don't change unless you know what you are doing
}

