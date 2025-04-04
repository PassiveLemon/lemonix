{ config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../common/system.nix
  ];

  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
    };
    kernelModules = [ "iwlwifi" ];
    kernelParams = [
      "mem_sleep_default=deep"
      "nmi_watchdog=0"
      "quiet"
      "splash"
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
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBnOSJDixevSeo1KcgGHki45BWMJqOxfgOASvT5WFStB lemon@aluminum" ];
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      nvtopPackages.amd
      powertop
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
        CPU_MAX_PERF_ON_BAT = 70;

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;

        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;

        START_CHARGE_THRESH_BAT0 = 70;
        STOP_CHARGE_THRESH_BAT0 = 95;

        DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
      };
    };
    tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscaleAuthKey.path;
      extraUpFlags = [
        "--accept-routes"
      ];
    };
  };

  systemd = {
    services.wifi-reset = {
      description = "Fix WiFi after hibernation";
      serviceConfig = {
        Type = "oneshot";
        ExecStartPre = "/run/current-system/sw/bin/sleep 5";
      };
      script = ''
        systemctl restart NetworkManager
      '';
      wantedBy = [ "post-resume.target" ];
      after = [ "post-resume.target" ];
      path = [ pkgs.systemd ];
    };
  };

  nix = {
    settings = {
      cores = 4;
      max-jobs = 2;
    };
  };

  # Drives
  # 1 TB Crucial (Root)

  system.stateVersion = "23.11"; # Don't change unless you know what you are doing
}

