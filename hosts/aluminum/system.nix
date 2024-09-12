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
    kernelParams = [
      "mem_sleep_default=deep"
      "nmi_watchdog=0"
      "quiet"
      "splash"
      #"vga=current"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];
    plymouth.enable = true;
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  networking = {
    hostName = "aluminum";
    enableIPv6 = false;
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
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
          "wheel" "video" "audio" "networkmanager" "storage" "input"
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
    power-profiles-daemon.enable = lib.mkForce false;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 80;

        START_CHARGE_THRESH_BAT0 = 70;
        STOP_CHARGE_THRESH_BAT0 = 90;
      };
    };
    tailscale.enable = true;
  };

  powerManagement = {
    powertop.enable = false;
  };

  systemd = {
    services.wifi-reset = {
      description = "Fix WiFi after hibernation";
      serviceConfig.Type = "oneshot";
      script = ''
        modprobe -r mt7921e
        modprobe mt7921e
      '';
      wantedBy = [ "post-resume.target" ];
      after = [ "post-resume.target" ];
      path = [ pkgs.kmod ];
    };
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

