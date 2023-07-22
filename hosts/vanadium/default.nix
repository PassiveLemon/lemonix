{ inputs, outputs, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];
  
  # Boot
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
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
  };

  # Packages
  environment = {
    systemPackages = with pkgs; [
      dash bash nano unzip unrar p7zip curl wget git
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
      liveRestore = false;
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
      options = "--delete-older-than 3d";
    };
  };

  system.stateVersion = "23.05";
}
