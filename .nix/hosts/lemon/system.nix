{ config, pkgs, ... }: {
  # Boot
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 3;
      systemd-boot.enable = false;
      grub = {
        enable = true;
        version = 2;
        efiSupport = true;
        useOSProber = true;
        device = "nodev";
        gfxmodeEfi = "1920x1080";
        configurationLimit = 100;
      };
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [ "iwlwifi" ];
  };

  # Locale
  time = { 
    timeZone = "America/New_York";
    hardwareClockInLocalTime = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking = {
    hostName = "citrus-tree";
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
    pamixer playerctl networkmanager ethtool
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