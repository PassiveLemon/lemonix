{ config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
#   console = {
#     font = "Iosevka Nerd Medium";
#     keyMap = "us";

  # Networking
  networking = {
    hostName = "lemontree";
#      wireless = {
#        enable = true;
#        networks = {
#          Geek = {
#            psk = "omgwtf42";
#            pskRaw = "";
#          };
#        };
#      };
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

  # Packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # System
    xorg.xrandr bspwm sxhkd bash nano kitty gnome.gdm polybar picom-jonaburg
    # Programs
    gimp obs-studio github-desktop spotify betterdiscordctl steam vscode firefox gparted vlc mpv vlc
    # Utilies
    docker webtorrent_desktop protonvpn-gui p7zip megasync psmisc wget unzip git curl gnumake scrot htop neofetch feh rofi networkmanager
    # Customizations
    kora-icon-theme
    # Other
    #pkgs.linuxKernel.packages.linux_zen.rtl8821ce
  ];

  # Config
  services = {
    xserver = {
      enable = true;
      displayManager = {
        defaultSession = "none+bspwm";
        gdm.enable = true;
        autoLogin = {
          enable = true;
          user = "lemon";
        };
      };
      windowManager.bspwm = {
        enable = true;
        configFile = "/home/lemon/.config/bspwm/bspwmrc";
        sxhkd.configFile = "/home/lemon/.config/sxhkd/sxhkdrc";
      };
      #videoDrivers = [ "nvidia" ];
    };
    picom = {
      enable = true;
    };
    #polybar = {
      #enable = true;
      #script = "/home/lemon/.config/polybar/launch.sh";
    };
    autorandr = {
      enable = true;
      profiles = {
        "Lemon" = {
          fingerprint.DP1 = "<EDID>";
          config.DP1 = {
              enable = true;
              primary = true;
              mode = "1920x1080";
              rate = "144.00";
          };
        };
        "Lime" = {
          fingerprint.DP2 = "<EDID>";
          config.DP2 = {
            enable = false;
            primary = true;
            mode = "1920x1080";
            rate = "60.00";
          };
        };
      };
    };
  };

  qt5 = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;


  # Specific Use Case
  #virtualisation.vmware.guest.enable = true;

  system.stateVersion = "22.11";
}
