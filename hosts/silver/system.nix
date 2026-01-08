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
    blacklistedKernelModules = [ "nouveau" "nova_core" ];
    kernelModules = [ "iwlwifi" "kvm-amd" ];
  };

  networking = {
    hostName = "silver";
    interfaces = {
      "eno1" = {
        ipv4 = {
          addresses = [{
            address = "192.168.1.10";
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
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbedW5DDGCzGpbym2f0Ex+efnyfzFfHRPAhDFY9ZI5K root@silver"
        ];
      };
      "lemon" = {
        uid = 1100;
        description = "Lemon";
        home = "/home/lemon";
        hashedPassword = "$6$J7q0.RZ88OJiQRkq$mQx2d32YHf6IXqZNMSv.o/sslQMgBAGIKID2aL6tLpN6XFpXp2Fda5p1Yi78H/cXOolBPIuXEQPzxhmKp5qWc0";
        extraGroups = [
          "wheel" "networkmanager" "video" "audio" "storage" "input" "uinput" "dialout"
          "docker" "kvm" "libvirtd"
          "docker-management" "borg-management"
        ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHteP0JhNBJOlom+X8PY8s0FXPdUY4VcV6PgPPzXIKi lemon@silver"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXRE/wC3EAMvJiRIpWv/Rl1+UfwmxF0p8M+YpUkelmU lemon@aluminum"
        ];
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

  virtualisation = {
    libvirtd.enable = true;
  };

  hardware = {
    uinput.enable = true;
    nvidia = let
      nvidia-package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "580.95.05";
        sha256_64bit = "sha256-hJ7w746EK5gGss3p8RwTA9VPGpp2lGfk5dlhsv4Rgqc=";
        openSha256 = "sha256-RFwDGQOi9jVngVONCOB5m/IYKZIeGEle7h0+0yGnBEI=";
        settingsSha256 = "sha256-F2wmUEaRrpR1Vz0TQSwVK4Fv13f3J9NJLtBe4UP2f14=";
        usePersistenced = false;
      };
    in {
      # https://github.com/yshui/picom/issues/1488 and https://github.com/NixOS/nixpkgs/issues/467814
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      package = nvidia-package // {
        open = nvidia-package.overrideAttrs (prevAttrs: {
          patches = (prevAttrs.patches or [ ]) ++ [
            (pkgs.fetchpatch {
              name = "get_dev_pagemap.patch";
              url = "https://github.com/NVIDIA/open-gpu-kernel-modules/commit/3e230516034d29e84ca023fe95e284af5cd5a065.patch";
              hash = "sha256-BhL4mtuY5W+eLofwhHVnZnVf0msDj7XBxskZi8e6/k8=";
            })
          ];
        });
      };
      open = true;
      modesetting.enable = true;
      powerManagement.enable = true;
    };
  };

  systemd = {
    tmpfiles.rules = [
      "Z /data 777 root root - -"
    ];
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
    "/data/HDD2TBEXT4" = {
      device = "/dev/disk/by-uuid/c532ca53-130a-46c6-9e06-3aee4fd8b6e2";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    # 1 TB Toshiba
    "/data/BACKUPDRIVE" = {
      device = "/dev/disk/by-uuid/76946991-d872-4936-82f2-298225ea010b";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  system.stateVersion = "23.05"; # Don't change unless you know what you are doing
}

