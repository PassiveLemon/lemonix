{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/default.nix
    ../../modules/nixos/swap.nix
  ];

  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [ "iwlwifi" ];
  };

  networking = {
    hostName = "aluminum";
    nameservers = [ "192.168.1.177" "1.1.1.1" ];
  };

  users = {
    users = {
      "lemon" = {
        description = "Lemon";
        home = "/home/lemon";
        hashedPassword = "$6$cVhBvZ0RiacmsWNS$4vT6O9R9Bo62kXCQVBSsqVtbpiNbwuI6Eb4fE.2.EVYGuoNEjy16ZWwZfHom6JQSOau20K92U3sZjbPo07XSa.";
        extraGroups = [ "wheel" "video" "audio" "networkmanager" "storage" ];
        isNormalUser = true;
      };
    };
  };

  services = {
    fwupd.enable = true;
    thermald.enable = true;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "powersave";
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 40;
      };
    };
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    gvfs.enable = true;
    devmon.enable = true;
    journald.extraConfig = "SystemMaxUse=1G";
  };

  powerManagement.enable = true;

  nix = {
    settings = {
      cores = 8;
      max-jobs = 1;
    };
  };

  # Drives
  # 128 GB Internal (Root)

  system.stateVersion = "23.11";
}
