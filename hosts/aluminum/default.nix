{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];
  
  # Boot
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 3;
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        useOSProber = true;
        device = "nodev";
        gfxmodeEfi = "1920x1080";
        configurationLimit = 50;
      };
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [ "rtl8821ce" ];
  };

  # Locale
  time = { 
    timeZone = "America/New_York";
    hardwareClockInLocalTime = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking = {
    hostName = "aluminum";
    networkmanager.enable = true;
    firewall.enable = true;
    nameservers = [ "192.168.1.177" "1.1.1.1" "8.8.8.8" ];
  };

  # Users
  users = {
    users = {
      lemon = {
        description = "Lemon";
        home = "/home/lemon";
        extraGroups = [ "wheel" "networkmanager" ];
        isNormalUser = true;
      };
    };
  };

  # Packages
  environment = {
    systemPackages = with pkgs; [
      dash bash
      nano unzip unrar p7zip curl wget git gvfs psmisc
      htop sysstat iotop stress netcat lm_sensors
      networkmanager
    ];
    binsh = "${pkgs.dash}/bin/dash";
    shells = with pkgs; [ bash ];
  };

  # Configs
  services.journald.extraConfig = "SystemMaxUse=1G";
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        intel-media-driver
      ];
    };
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

  # Drives
  # To be added

  system.stateVersion = "to be added";
}
