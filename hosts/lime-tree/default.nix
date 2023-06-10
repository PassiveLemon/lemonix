{ inputs, outputs, config, pkgs, ... }: {
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
    hostName = "lime-tree";
    networkmanager.enable = true;
  };

  # Users
  users = {
    users = {
      lemon = {
        description = "Lemon";
        home = "/home/lemon";
        extraGroups = [ "wheel" "networkmanager" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6XpVE0Tj3gEOcTwWAODH2Sm7u6smE9kwZ0Z4ZV4q9Nc/cH+f0DXKLOljswW2iu0cj8tEsANu5P8JIt+oMA3HXy4qSIzKnaVP7a5/rEQ+yoVwF4AdqzLHKd39D9GP9zDDz0UO4ZaxYEg9q206BHOkS4StpRy1fpES2TneNd/7477mjJbboIyDJK1EzUfQoU/fP9FiSnpWbZKrQtK0m/iol5+2AB8Qp/5htMVm9+KXftCO15cydbi9UKJzJll4SFa8y09/GV/Rgqua5Wj7KH4cDgzXqpIPRo63H0XqfVLjOH1NHeyxX+pmuNZuFGbrqBWF7AtuFGmpujAp9K7tIfkGTi/mJi5rSq+ejiAwJzw7qldGQw8rsfsKVU5pS22JE56X/XYfgmf95ds5lYzTjgx5juVbdjvY3uq6It/JKbvHCP0ueUT78H0RtDRthew0VXq91QWJMrRmwFlc6JRFobk4EcqnWc0kz6aJ6p3SRGymscX/0+UaS/KyyPKSTIVrAaY8= lemon@lemon-tree" ];
      };
    };
  };

  # Packages
  environment = {
    systemPackages = with pkgs; [
      dash bash nano unzip unrar p7zip curl wget git gvfs psmisc
      htop sysstat iotop stress nvtop-nvidia
      networkmanager ethtool
      exa trashy
    ];
    binsh = "${pkgs.dash}/bin/dash";
    shells = with pkgs; [ bash ];
  };

  # Configs
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
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
      options = "--delete-older-than 14d";
    };
  };
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "openssl-1.1.1u"
    ];
  };

  # Drives
  # 2 Gb Swap
  swapDevices = [
    { device = "to be added"; randomEncryption.enable = true; priority = 176; }
  ];

  system.stateVersion = "to be added";
}
