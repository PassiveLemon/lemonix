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

  # Services
  services = {
    xserver = {
      enable = true;
      displayManager = {
        defaultSession = "xfce+bspwm";
        lightdm.enable = true;
        };
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
      windowManager.bspwm = {
        enable = true;
        configFile = "/home/lemon/.config/bspwm/bspwmrc";
        sxhkd.configFile = "/home/lemon/.config/sxhkd/sxhkdrc";
      };
      excludePackages = [ pkgs.xterm pkgs.xfce.xfce4-terminal pkgs.xfce.xfwm4 pkgs.xfce.mousepad ];
      videoDrivers = [ "nvidia" ];
    };
    picom.enable = true;
    gnome.gnome-keyring.enable = true;
    openssh.enable = true;
  };
  hardware.opengl.enable = true;

  # Programs
  programs = {
    dconf.enable = true;
    steam.enable = true;
    seahorse.enable = true;
    thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin thunar-volman
    ];
  };
  
  # Other
  security.pam.services.lemon.enableGnomeKeyring = true;
}