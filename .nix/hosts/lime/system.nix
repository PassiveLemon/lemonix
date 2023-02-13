{ config, pkgs, ... }: {
  # Boot
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 100;
      };
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen.rtl8821ce;
    extraModulePackages = [ config.boot.kernelPackages.rtl8821ce ];
  };

  # Locale
  time = { 
    timeZone = "America/New_York";
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking = {
    hostName = "citrus-tree";
    networkmanager.enable = true;
  };

  # Users
  users.users.lemon = {
    isNormalUser = true;
    home = "/home/lemon";
    description = "Lemon";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    bash nano unzip unrar p7zip curl wget git psmisc
    pamixer playerctl networkmanager
  ];

  # Configs
  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
    printing.enable = true;
    avahi = {
      enable = true;
      openFirewall = true;
    };
  };
  security.rtkit.enable = true;
  xdg.portal.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
}