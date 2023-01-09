{ config, pkgs, ... }:

{
  # Specific Use Case
#  virtualisation.vmware.guest.enable = true;

  # Packages
  environment.systemPackages = with pkgs; [
    bash nano unzip curl wget cmake git
    docker psmisc networkmanager p7zip wireless-tools
#    pkgs.linuxKernel.packages.linux_zen.rtl8821ce
  ];

  # Boot
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
#    extraModulePackages = [ config.boot.kernelPackages.rtl8821ce ];
    kernelModules = [ "iwlwifi" "iwlmvm "]; 
  };

  # Locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
#  console = {
#    font = "Fira Code";
#    keyMap = "us";
#  };

  # Audio
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Networking
  networking = {
    hostName = "lemon-tree";
    networkmanager.enable = true;
#    wireless = {
#      enable = true;
#      networks = {
#        Geek = {
#          psk = "censored";
#          pskRaw = "";
#        };
#      };
#    };
#    interfaces.eth0.ipv4.addresses = [ {
#      address = "192.168.1.178";
#      prefixLength = 24;
#    } ];
  };

  # Users
  users.users.lemon = {
    isNormalUser = true;
    home = "/home/lemon";
    description = "Lemon";
    extraGroups = [ "wheel" "networkmanager" ];
  };
}
