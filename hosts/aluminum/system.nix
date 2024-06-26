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
    kernelModules = [ "iwlwifi" ];
    kernelParams = [ "mem_sleep_default=deep" "nmi_watchdog=0" ];
  };

  networking = {
    hostName = "aluminum";
    nameservers = [ "192.168.1.177" "1.1.1.1" "9.9.9.9" ];
  };

  users = {
    users = {
      "root" = {
        home = "/root";
        hashedPassword = "!";
      };
      "lemon" = {
        uid = 1100;
        description = "Lemon";
        home = "/home/lemon";
        hashedPassword = "$6$cVhBvZ0RiacmsWNS$4vT6O9R9Bo62kXCQVBSsqVtbpiNbwuI6Eb4fE.2.EVYGuoNEjy16ZWwZfHom6JQSOau20K92U3sZjbPo07XSa.";
        extraGroups = [
          "wheel" "video" "audio" "networkmanager" "storage"
        ];
        isNormalUser = true;
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      nvtopPackages.amd
      powertop
    ];
  };

  services = {
    fwupd.enable = true;
    thermald.enable = true;
    upower.enable = true;
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  nix = {
    settings = {
      cores = 8;
      max-jobs = 1;
    };
  };

  # Drives
  # 1 TB Crucial (Root)

  system.stateVersion = "23.11";
}
