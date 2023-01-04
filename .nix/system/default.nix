{ config, pkgs, ... }:

{
  # Specific Use Case
#  virtualisation.vmware.guest.enable = true;

  # Boot
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
#    extraModulePackages = [ config.boot.kernelPackages.rtl8821ce ];
#    kernelModules = [ "iwlwifi" "iwlmvm "]; 
  };

  # Locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Fira Code";
    keyMap = "us";
  };

  # Audio
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Networking
  networking = {
    hostName = "lemon-tree";
#    networkmanager.enable = true;
#    wireless = {
#      enable = true;
#      networks = {
#        Geek = {
#          psk = "omgwtf42";
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

  # Packages
  environment.systemPackages = with pkgs; [
    dunst xorg.xrandr bspwm sxhkd bash nano kitty gnome.gdm polybar picom-jonaburg
#    pkgs.linuxKernel.packages.linux_zen.rtl8821ce
  ];

  # Config
  services = {
    xserver = {
      enable = true;
      desktopManager = {
        default = "xfce";
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
      displayManager = {
        defaultSession = "xfce+bspwm";
        gdm.enable = true;
        };
      windowManager.bspwm = {
        enable = true;
        configFile = "/home/lemon/.config/bspwm/bspwmrc";
        sxhkd.configFile = "/home/lemon/.config/sxhkd/sxhkdrc";
      };
#      videoDrivers = [ "nvidia" ];
    };
    picom.enable = true;
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
}