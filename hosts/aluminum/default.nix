{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/default.nix
    ./hardware-configuration.nix
  ];
  
  # Boot
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 50;
      };
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [ "rtl8821ce" ];
  };

  # Networking
  networking = {
    hostName = "aluminum";
    nameservers = [ "192.168.1.178" ];
  };

  # Users
  users = {
    users = {
      "lemon" = {
        description = "Lemon";
        home = "/home/lemon";
        extraGroups = [ "wheel" "networkmanager" "storage" "video" ];
        isNormalUser = true;
      };
    };
  };

  # Configs
  services = {
    thermald.enable = true;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
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
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        intel-media-driver
      ];
    };
    bluetooth.enable = true;
  };
  powerManagement.enable = true;

  # Drives
  # 128 GB Internal (Root)

  system.stateVersion = "23.05";
}
