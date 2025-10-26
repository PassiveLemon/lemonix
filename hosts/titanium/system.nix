{ config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/system.nix
  ];

  age.secrets = {
    discordWebhook = {
      file = ../../secrets/discordWebhook.age;
      mode = "600";
      owner = "root";
      group = "management";
    };
  };

  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
    };
    kernelModules = [ "iwlwifi" "kvm-amd" ];
    kernelParams = [
      "nomodeset"
      "vga=normal"
      "video=vesafb:off"
      "video=efifb:off"
    ];
    blacklistedKernelModules = [
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
      "drm_kms_helper"
      "drm"
    ];
    swraid = {
      enable = true;
      mdadmConf = ''
        ARRAY /dev/md0 UUID=e53aed8f:e6224c4e:86f71ff5:1d0c884e

        PROGRAM bash ${lib.getExe (pkgs.writeShellApplication {
          name = "mdadm-discord-webhook";
          text = ''
            DISCORD_WEBHOOK_URL=$(cat ${config.age.secrets.discordWebhook.path})
            ${builtins.readFile ./webhook.sh}
          '';
          meta = with lib; {
            license = licenses.mit;
            mainProgrma = "mdadm-discord-webhook";
          };
        })}
      '';
    };
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
    groups = {
      "management" = {
        gid = 1204;
      };
    };
    users = {
      "root" = {
        home = "/root";
        hashedPassword = "!";
        extraGroups = [
          "docker-management" "borg-management"
        ];
        # The first key is just the users public key for easy reference.
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCBA9bX/zAfV04lQXGPPL+f24qD+MrX7zDt+odiE0pI root@titanium"
        ];
      };
      "lemon" = {
        uid = 1100;
        description = "Lemon";
        home = "/home/lemon";
        hashedPassword = "$6$rf1mpzpAbaL7ml1o$sRfhuqilsLdrxqmXLHobwnPfBFYlc4usBJE5ZfcOrv1duaTs5k6uGa9Hgc/Wb4uKSpWPDCiWgIVl7OyW2k7bd1";
        extraGroups = [
          "wheel" "networkmanager" "storage" "input"
          "docker" "kvm" "libvirtd"
          "management" "docker-management" "borg-management"
        ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINxpX0Uf3Bf1lSSCxvX+oTRsHD1tkBPWYzYFjSRqZ/MK lemon@titanium"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHteP0JhNBJOlom+X8PY8s0FXPdUY4VcV6PgPPzXIKi lemon@silver"
        ];
      };
      "monitor" = {
        uid = 1101;
        description = "Monitor";
        home = "/home/monitor";
        hashedPassword = "$6$8UYgx2knIzubEIcf$mPKCPdVJ0w5IU/hzNuz8kt0liDPOjxqZgE/DC4s6zY1biKeV3maGJo2jixjAfnkvYOXAWqgLe4N61h91cybSw/";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2BjYf5UkUCNgSo/z/7/lqCKtaenbeaFHI1GGdkj/ry monitor@titanium"
        ];
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

  systemd = {
    units."mdmonitor.service".enable = true;
    tmpfiles.rules = [
      "Z /data 775 root management - -"
      "Z /data/lemonix 770 root management - -"
    ];
  };

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
  # 500 GB Crucial T500 (Root)

  fileSystems = {
    # 2x 2 TB Crucial T500 RAID 1
    "/data" = {
      device = "/dev/disk/by-uuid/896ef644-96f6-4e06-b4d5-b5e7fb84faad";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  system.stateVersion = "25.05"; # Don't change unless you know what you are doing
}

