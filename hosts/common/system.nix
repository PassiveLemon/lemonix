{ outputs, lib, pkgs, ... }: {
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 3;
      grub = {
        efiSupport = true;
        useOSProber = true;
        device = "nodev";
        configurationLimit = 50;
      };
      systemd-boot = {
        consoleMode = "auto";
        configurationLimit = 50;
      };
    };
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };

  time = {
    timeZone = "America/New_York";
  };
  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  users = {
    mutableUsers = false;
  };

  environment = {
    systemPackages = with pkgs; [
      nano unzip unrar p7zip zip curl wget git gvfs psmisc
      htop sysstat iotop stress netcat lm_sensors smartmontools dig neofetch
      networkmanager ethtool
    ];
    shells = with pkgs; [ bashInteractive ];
  };

  services = {
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    gvfs.enable = true;
    devmon.enable = true;
    journald.extraConfig = "SystemMaxUse=1G";
  };

  security = {
    sudo.execWheelOnly = true;
    rtkit.enable = true;
  };

  systemd = {
    enableStrictShellChecks = true;
    services = {
      # Fixes for problematic services
      NetworkManager-wait-online.enable = false;
      cups-browsed.serviceConfig.TimeoutStopSec = 10;
      # System sometimes hangs during expensive builds
      "nix-daemon".serviceConfig = {
        Slice = "nix-daemon.slice";
        OOMScoreAdjust = 1000;
      };
      # https://github.com/NixOS/nixpkgs/pull/370910
      # It was not backported so we gotta keep it here
      cron.preStart = lib.mkForce ''
        mkdir -m 710 /var/cron || true

        # By default, allow all users to create a crontab.  This
        # is denoted by the existence of an empty cron.deny file.
        if ! test -e /var/cron/cron.allow -o -e /var/cron/cron.deny; then
            touch /var/cron/cron.deny
        fi
      '';
    };
    slices."nix-daemon".sliceConfig = {
      CPUAccounting = true;
      CPUQuota = "80%";
      MemoryAccounting = true;
      MemoryHigh = "70%";
      MemoryMax = "80%";
      MemorySwapMax = "70%";
      MemoryZSwapMax = "70%";
    };
  };

  powerManagement = {
    enable = true;
  };

  nix = {
    settings = {
      fallback = true;
      keep-going = true;
      use-xdg-base-directories = true;
      warn-dirty = false;
      experimental-features = [ "flakes" "nix-command" ];
      allowed-users = [ "@wheel" ];
      trusted-users = [ "@wheel" ];
      substituters = [ "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://passivelemon.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "passivelemon.cachix.org-1:ScYjLCvvLi70S95SMMr8lMilpZHuafLP3CK/nZ9AaXM="
      ];
    };
    optimise = {
      automatic = true;
      dates = [ "Sat" ];
    };
    gc = {
      automatic = true;
      dates = "Sat";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
    overlays = [
      outputs.overlays.packages
    ];
  };
}

