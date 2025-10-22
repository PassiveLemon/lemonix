{ ... }: {
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
    # swraid = {
    #   enable = true;
    #   mdadmConf = ''
      
    #   '';
    # };
  };

  networking = {
    hostName = "titanium";
    interfaces = {
      "eno1" = {
        ipv4 = {
          addresses = [{
            address = "192.168.1.11";
            prefixLength = 24;
          }];
        };
        useDHCP = false;
      };
    };
    enableIPv6 = false;
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
  };

  users = {
    users = {
      "root" = {
        home = "/root";
        hashedPassword = "!";
        extraGroups = [
          "docker-management" "borg-management"
        ];
        # The first key is just the users public key for easy reference.
        openssh.authorizedKeys.keys = [ ];
      };
      "lemon" = {
        uid = 1100;
        description = "Lemon";
        home = "/home/lemon";
        hashedPassword = "xxxxxxxxxxx";
        extraGroups = [
          "wheel" "networkmanager" "storage" "input"
          "docker" "kvm" "libvirtd"
          "docker-management" "borg-management"
        ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "xxxxxxxxx"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHteP0JhNBJOlom+X8PY8s0FXPdUY4VcV6PgPPzXIKi lemon@silver"
        ];
      };
      "monitor" = {
        uid = 1101;
        description = "Monitor";
        home = "/home/monitor";
        hashedPassword = "xxxxxxxxx";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ ];
      };
    };
  };

  # services = {
  #   create_ap = {
  #     enable = true;
  #     settings = {
  #       INTERNET_IFACE = "enp7s0";
  #       WIFI_IFACE = "wlp6s0";
  #       SSID = "Unknown Network";
  #       PASSPHRASE = "kXP3@%p!k%N7KL!4#26Z3";
  #       IEEE80211N = 1;
  #       IEEE80211AC = 1;
  #       HT_CAPAB = "[HT40+][SHORT-GI-40][MAX-AMSDU-7935][TX-STBC][RX-STBC2][LDPC][DSSS_CCK-40]";
  #       VHT_CAPAB = "[SHORT-GI-160][MAX-MPDU-11454][TX-STBC][RX-STBC-2][LDPC]";
  #       FREQ_BAND = 5;
  #       HIDDEN = 1;
  #       COUNTRY = "US";
  #       ISOLATE_CLIENTS = 1;
  #     };
  #   };
  # };

  hardware.nvidia.modesetting.enable = false; # For the GT 8400

  virtualisation = {
    libvirtd.enable = true;
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
    # 4 TB Crucial T500 Volume
    "/data" = {
      device = "/dev/disk/by-uuid/xxxxxxxxxxxxx";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  system.stateVersion = "25.05"; # Don't change unless you know what you are doing
}

