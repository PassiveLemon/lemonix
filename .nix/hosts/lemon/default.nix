{ config, pkgs, ... }: {
  imports = [
    ./user.nix
  ];

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
        configurationLimit = 50;
      };
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [ "iwlwifi" "r8169" ];
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
  users = {
    users.lemon = {
      isNormalUser = true;
      home = "/home/lemon";
      description = "Lemon";
      extraGroups = [ "wheel" "networkmanager" "docker" "video" ];
    };
  };

  # Packages
  environment = {
    systemPackages = with pkgs; [
      dash bash nano unzip unrar p7zip curl wget git gvfs psmisc
      networkmanager ethtool
      exa trashy
      docker nvidia-docker distrobox virt-manager OVMF pciutils virtiofsd
    ];
    binsh = "${pkgs.dash}/bin/dash";
    shells = with pkgs; [ bash ];
  };

  # Configs
  services = {
    openssh.enable = true;
  };
  virtualisation = {
    docker = { 
      enable = true;
      enableNvidia = true;
      liveRestore = false;
    };
  };
  hardware = {
    nvidia.open = true;
    opengl = {
      enable = true;
      driSupport = true;
    };
  };
  systemd.services = {
    Ethernet1 = {
      preStart = "/run/current-system/sw/bin/sleep 10";
      serviceConfig = {
        User = "root";
        ExecStart = "/run/current-system/sw/bin/ethtool -s enp6s0 autoneg off speed 100 duplex full";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Drives
  # 2 Gb Swap
  swapDevices = [
    { device = "/dev/disk/by-uuid/c99f7496-c915-4dc4-89e5-a6690a3d93f1"; }
  ];

  # 2 TB Seagate
  fileSystems."/home/HDD2TBEXT4" = {
    device = "/dev/disk/by-uuid/c532ca53-130a-46c6-9e06-3aee4fd8b6e2";
    fsType = "ext4";
  };

  # 1 TB Toshiba
  fileSystems."/home/BACKUPDRIVE" = {
    device = "/dev/disk/by-uuid/76946991-d872-4936-82f2-298225ea010b";
    fsType = "ext4";
  };

  system.stateVersion = "22.11";
}
