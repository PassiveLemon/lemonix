{ config, pkgs, ... }: {
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
        { from = 22; to = 22;}
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
    extraGroups = [ "wheel" "networkmanager" "docker" "libvertd" "video" ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    bash nano unzip unrar p7zip curl wget git cmake gnumake
    docker nvidia-docker virt-manager OVMF pciutils virtiofsd psmisc networkmanager home-manager
  ];

  # Configs
  virtualisation = {
    docker = { 
      enable = true;
      enableNvidia = true;
    };
    libvirtd.enable = true;
  };
  hardware = {
    nvidia.open = true;
    opengl.enable = true;
  };

  services.openssh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
}