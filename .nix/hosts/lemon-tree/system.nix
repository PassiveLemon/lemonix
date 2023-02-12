{ config, pkgs, ... }: {
  # Boot
  boot = {
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      timeout = 3;
      grub = {
        enable = true;
        version = 2;
        useOSProber = true;
        efiSupport = true;
        device = "nodev";
        gfxmodeEfi = "1920x1080";
      };
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [ "iwlwifi" "iwlmvm" ];
    #kernelParams = [ "amd_iommu=on" ];
  };

  # Locale
  time = { 
    timeZone = "America/New_York";
    hardwareClockInLocalTime = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking = {
    hostName = "lemon-tree";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        { from = 22; to = 22;}
        { from = 21000; to = 23000; }
        { from = 31000; to = 33000; }
        { from = 41000; to = 43000; }
      ];
      allowedUDPPortRanges = [
        { from = 989; to = 989; }
      ];
    };
    wlanInterfaces = {
      Ethernet = {
        device = "enp6s0";
        mac = "f0:2f:74:d4:67:e3";
      };
    };
  };

  # Users
  users.users.lemon = {
    isNormalUser = true;
    home = "/home/lemon";
    description = "Lemon";
    extraGroups = [ "wheel" "networkmanager" "docker" "libvertd" "video" ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    bash nano unzip unrar p7zip curl wget git gnumake
    docker nvidia-docker virt-manager OVMF pciutils virtiofsd psmisc
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
    openssh.enable = true;
    flatpak.enable = true;
  };
  virtualisation = {
    docker = { 
      enable = true;
      enableNvidia = true;
      liveRestore = false;
    };
    libvirtd.enable = true;
  };
  hardware = {
    nvidia.open = true;
    opengl = {
      enable = true;
      driSupport = true;
    };
  };
  security.rtkit.enable = true;
  xdg.portal.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
}