{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/system.nix
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
    #firewall = {
    #  allowedTCPPorts = [
    #    5500 # HTML Webserver for testing
    #  ];
    #};
    #interfaces = {
    #  "enp7s0" = {
    #    ipv4.addresses = [{
    #      address = "192.168.1.177";
    #      prefixLength = 24;
    #    }];
    #    useDHCP = false;
    #  };
    #};
    enableIPv6 = false;
    nameservers = [ "127.0.0.1" "1.1.1.1" "9.9.9.9" ];
  };

  users = {
    users = {
      "root" = {
        home = "/root";
        hashedPassword = "!";
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbedW5DDGCzGpbym2f0Ex+efnyfzFfHRPAhDFY9ZI5K root@silver" ];
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
    };
  };

  environment = {
    systemPackages = with pkgs; [
      nvtopPackages.nvidia
    ];
  };

  services = {
    tailscale.enable = true;
    #create_ap = {
    #  enable = true;
    #  settings = {
    #    INTERNET_IFACE = "enp7s0";
    #    WIFI_IFACE = "wlp6s0";
    #    SSID = "Unknown Network";
    #    PASSPHRASE = "kXP3@%p!k%N7KL!4#26Z3";
    #    IEEE80211N = 1;
    #    IEEE80211AC = 1;
    #    HT_CAPAB = "[HT40+][SHORT-GI-40][MAX-AMSDU-7935][TX-STBC][RX-STBC2][LDPC][DSSS_CCK-40]";
    #    VHT_CAPAB = "[SHORT-GI-160][MAX-MPDU-11454][TX-STBC][RX-STBC-2][LDPC]";
    #    FREQ_BAND = 5;
    #    HIDDEN = 1;
    #    COUNTRY = "US";
    #    ISOLATE_CLIENTS = 1;
    #  };
    #};
  };

  virtualisation = {
    libvirtd.enable = true;
  };

  hardware = {
    nvidia = {
      # Commented out until they fix the build
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "555.58.02";
        sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
        sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
        openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
        settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
        persistencedSha256 = "sha256-a1D7ZZmcKFWfPjjH1REqPM5j/YLWKnbkP9qfRyIyxAw=";
      };
      modesetting.enable = true;
      powerManagement.enable = true;
    };
  };

  nixpkgs = {
    config.cudaSupport = true;
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

