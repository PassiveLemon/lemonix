{ inputs, outputs, pkgs, config, lib, ... }: {
  # Boot
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 3;
      systemd-boot.enable = false;
    };
  };

  # Locale
  time = { 
    timeZone = "America/New_York";
    hardwareClockInLocalTime = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Users
  users = {
    users = {
      "root" = {
        hashedPassword = null;
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      dash bash
      nano unzip unrar p7zip curl wget git gvfs psmisc
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
  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100;
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
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };
}
