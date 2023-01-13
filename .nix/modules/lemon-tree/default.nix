{ config, pkgs, home-manager, spicetify, ... }: {
  imports = [
    ./lemon.nix
  ];

  # Boot
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelModules = [ "iwlwifi" "iwlmvm "]; 
  };

  # Locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Audio
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Networking
  networking = {
    hostName = "lemon-tree";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        { from = 21000; to = 23000; }
        { from = 31000; to = 33000; }
        { from = 41000; to = 43000; }
      ];
    };
  };

  # Users
  users.users.lemon = {
    isNormalUser = true;
    home = "/home/lemon";
    description = "Lemon";
    extraGroups = [ "wheel" "networkmanager" "docker" "libvertd" ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    bash nano unzip p7zip curl wget git cmake gnumake
    docker virt-manager psmisc networkmanager
  ];
}