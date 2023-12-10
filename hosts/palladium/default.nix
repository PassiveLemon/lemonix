{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];
  
  # Boot
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 3;
      systemd-boot.enable = false;
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
    ];
    kernelPackages = pkgs.linuxPackages_rpi4;
  };

  # Locale
  time = { 
    timeZone = "America/New_York";
    hardwareClockInLocalTime = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking = {
    hostName = "palladium";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        { from = 40000; to = 44000; }
        { from = 22; to = 22; }
        { from = 2375; to = 2375; }
      ];
      allowedUDPPortRanges = [
        { from = 53; to = 53; } 
      ];
    };
    interfaces = {
      end0 = {
        ipv4.addresses = [{
          address = "192.168.1.178";
          prefixLength = 24;
        }];
        useDHCP = false;
      };
    };
    enableIPv6 = false;
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Users
  users = {
    groups = {
      gpio = { };
    };
    users = {
      root = {
        hashedPassword = null;
      };
      nixos = {
        description = "NixOS";
        home = "/home/nixos";
        extraGroups = [ "wheel" "networkmanager" "docker" "video" "storage" "gpio" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWKTvSQ2O9qNMyhg5EakyDNQVK9O3dDuPlH1Wfo3DkA0aGb14YfcGj07bQpdJ5RrebNSMwATxiEU0GuTazZqnjTtG5mP3R3Z1vQS2LTVEXyU6UiHatMqJxqerKshMJBVyLc2Rn4/c2Uj88I3NPnxqt4H/Xz4hbhNLOeuPtB9Arj/xzglc3BJQ14ctjxjkT41fkic+7VQUhq9VbbmOiC8Hs68T/cWk2QZaA/2QvF+3wPlhh27WJdfHX1xJrKYe20IV7JU5199LtStYCwOHMnHX2iTARWQFNYfsatyBMEGjbO6sFwDs9NWPjqA4s0IG/D2jWi8QkB/YgkN+7XDELE0S/rxT5hLOCuScv3ozL8pB1aWZirTuVodg5n/MJ/WcaM/J3Gg2phnGgPuqnjpDUdwQSQlcfFEmqqlZEhR5Ei5QJMxrlPtMRcZbZv6reLvllZUNM5xTOuxKUSkABcMUam8jx7q2qQcIg6nJGOO+Q85NTp0dKKn/AJ7SAJTar1K4X1VU= nixos@palladium" ];
      };
      monitor = {
        description = "Monitor";
        home = "/home/monitor";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCygp+qM5kt3pTDQB7Et4s04iP7DCuQCD3qZxNzWqQwAi7wZUA6fChB/GhSuzfG6VmhIu2N6J+ZnuuyFeUOh+QykxyIZmki7q7sNhDsittIlGwPnEiInSB6m1W8MkpFKDIzPnFgn1usFeOYT2jYXYaOLlln6zKkXyphiiN5xJ68EJZw2mmx1ckqaGYqV1KfPwBAPsQhwZg5VHnc/kJjzbhTH1eqPbuArKfKhytJ9frXhWr2Dqvp8wXK+I6PXMaTrI+iN5zX3YtdGOnFY5eib0GmKQ0tYBVDWXOey5UZKqFeUf+CdXiSlsc82jOBkw4W4qkE5bck+2fOAiEy0HYiQqQ6VoJCZdh51nA6SEr46Zfx3vd9wViepaymHZmRo4yfVgujte3fOS0j0LSZVk/e6KtWLema/cx7bMmUCN6Wz5mj1KAPMHJnJBc3wkNSNOtbZrXlftjzehbl905nTY54wHpdBWnrafaijWVeer3gsMOHiPUuXCIi1KbncwRc6yEINdc= monitor@palladium" ];
      };
    };
  };

  # Packages
  environment = {
    systemPackages = with pkgs; [
      dash bash
      nano unzip unrar p7zip curl wget git gvfs psmisc
      htop sysstat iotop stress netcat lm_sensors smartmontools dig
      networkmanager ethtool
      libraspberrypi raspberrypi-eeprom
      neofetch
    ];
    binsh = "${pkgs.dash}/bin/dash";
    shells = with pkgs; [ bash ];
  };

  # Configs
  services = {
    openssh = {
      enable = true;
      extraConfig = ''
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AllowTcpForwarding yes
        AuthenticationMethods publickey
        ChallengeResponseAuthentication no
        KbdInteractiveAuthentication no
        PasswordAuthentication no
        PermitEmptyPasswords no
        PermitRootLogin no
        X11Forwarding no
      '';
    };
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    gvfs.enable = true;
    devmon.enable = true;
    journald.extraConfig = "SystemMaxUse=500M";
    udev.extraRules = ''
      SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio", MODE="0660"
      SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio  /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
      SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add",RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
    '';
  };
  virtualisation = {
    docker = { 
      enable = true;
      enableOnBoot = true;
      liveRestore = false;
      autoPrune = {
        enable = true;
        dates = "monthly";
      };
      daemon.settings = {
        hosts = [ "unix:///var/run/docker.sock" "tcp://0.0.0.0:2375" ];
      };
    };
  };
  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
    enableRedistributableFirmware = true;
  };
  security = {
    sudo.execWheelOnly = true;
    rtkit.enable = true;
  };
  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100;
  };
  documentation = {
    enable = false;
    doc.enable = false;
    man.enable = false;
    dev.enable = false;
  };
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  # Drives
  # 32 GB SD (Root)

  # 16 GB Sandisk (Home)
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/fc95e5c7-b812-437e-93ac-64205074f1fb";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  system.stateVersion = "23.05";
}
