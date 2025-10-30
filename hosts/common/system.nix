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
    kernelParams = [
      "net.ifnames=1" 
      "biosdevname=0"
    ];
  };

  time = {
    timeZone = "America/New_York";
  };
  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
    usePredictableInterfaceNames = true;
  };

  users = {
    mutableUsers = false;
  };

  environment = {
    systemPackages = with pkgs; [
      nano unzip unrar p7zip zip curl wget git gvfs psmisc
      htop iotop sysstat netcat dig lm_sensors smartmontools neofetch
      networkmanager ethtool stress
      sbctl
    ];
    shells = with pkgs; [ bashInteractive ];
  };

  services = {
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    earlyoom = {
      enable = true;
      freeSwapThreshold = 5;
      freeMemThreshold = 5;
      enableNotifications = true;
      extraArgs = [
        "-g" "--avoid" "'^(X|.awesome-wrappe|pipewire|tym|lite-xl)$'"
      ];
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
    oomd = {
      enable = true;
      enableRootSlice = true;
      enableUserSlices = true;
    };
    services = {
      # Workarounds for problematic services
      NetworkManager-wait-online.enable = false;
      cups-browsed.serviceConfig.TimeoutStopSec = 10;
    };
  };

  powerManagement = {
    enable = true;
  };

  # Experimental
  boot.tmp.useTmpfs = true;
  boot.tmp.cleanOnBoot = true;
  boot.initrd.systemd.enable = true;
  services.dbus.implementation = "broker";
  services.irqbalance.enable = true;
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
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
      dates = [ "Sun" ];
    };
    gc = {
      automatic = true;
      dates = "Sun";
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

