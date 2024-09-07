{ inputs, outputs, pkgs, config, lib, ... }: {
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
        consoleMode = "max";
        configurationLimit = 50;
      };
    };
  };

  time = {
    timeZone = "America/New_York";
    hardwareClockInLocalTime = true;
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
      dash bash
      nano unzip unrar p7zip zip curl wget git gvfs psmisc
      htop sysstat iotop stress netcat lm_sensors smartmontools dig neofetch
      networkmanager ethtool
    ];
    binsh = "${pkgs.dash}/bin/dash";
    shells = with pkgs; [ bash ];
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
    services = {
      NetworkManager-wait-online.enable = false;
      "nix-daemon".serviceConfig = {
        Slice = "nix-daemon.slice";
        OOMScoreAdjust = 1000;
      };
    };
    # System likes to hang during expensive builds so we apply some limits
    slices."nix-daemon".sliceConfig = {
      CPUQuota = "80%";
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "80%";
    };
  };

  powerManagement = {
    enable = true;
  };

  documentation = {
    enable = false;
    doc.enable = false;
    man.enable = false;
    dev.enable = false;
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
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

