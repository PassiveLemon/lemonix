{ inputs, outputs, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];
  
  # Boot
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 3;
      systemd-boot = {
        enable = true;
        configurationLimit = 50;
      };
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
    hostName = "vanadium";
    nameservers = [ "192.168.1.177" "1.1.1.1" "8.8.8.8" ];
  };

  # Packages
  environment = {
    systemPackages = with pkgs; [
      dash bash nano unzip unrar p7zip curl wget git
      htop sysstat iotop stress nvtop-nvidia netcat lm_sensors
    ];
    binsh = "${pkgs.dash}/bin/dash";
    shells = with pkgs; [ bash ];
  };

  # Configs
  services = {
    openssh = {
      enable = true;
    };
  };
  virtualisation = {
    docker = { 
      enable = true;
      enableNvidia = true;
      liveRestore = false;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };
  hardware = {
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      powerManagement.enable = true;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };
  nix = {
    settings = {
      experimental-features = [ "nix-command" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
  };
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  system.stateVersion = "23.05";
}
