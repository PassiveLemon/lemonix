{ inputs, outputs, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];
  
  # Boot
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 3;
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        useOSProber = true;
        device = "nodev";
        gfxmodeEfi = "1920x1080";
        configurationLimit = 50;
      };
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [ "iwlwifi" "kvm-amd" ];
  };

  # Locale
  time = { 
    timeZone = "America/New_York";
    hardwareClockInLocalTime = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Networking
  networking = {
    hostName = "silver";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        { from = 22; to = 22;}
        { from = 50000; to = 55000; }
      ];
      allowedUDPPortRanges = [
        { from = 989; to = 989; }
      ];
    };
  };

  # Users
  users = {
    users = {
      lemon = {
        description = "Lemon";
        home = "/home/lemon";
        extraGroups = [ "wheel" "networkmanager" "docker" "video" "kvm" "libvirtd" ];
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6XpVE0Tj3gEOcTwWAODH2Sm7u6smE9kwZ0Z4ZV4q9Nc/cH+f0DXKLOljswW2iu0cj8tEsANu5P8JIt+oMA3HXy4qSIzKnaVP7a5/rEQ+yoVwF4AdqzLHKd39D9GP9zDDz0UO4ZaxYEg9q206BHOkS4StpRy1fpES2TneNd/7477mjJbboIyDJK1EzUfQoU/fP9FiSnpWbZKrQtK0m/iol5+2AB8Qp/5htMVm9+KXftCO15cydbi9UKJzJll4SFa8y09/GV/Rgqua5Wj7KH4cDgzXqpIPRo63H0XqfVLjOH1NHeyxX+pmuNZuFGbrqBWF7AtuFGmpujAp9K7tIfkGTi/mJi5rSq+ejiAwJzw7qldGQw8rsfsKVU5pS22JE56X/XYfgmf95ds5lYzTjgx5juVbdjvY3uq6It/JKbvHCP0ueUT78H0RtDRthew0VXq91QWJMrRmwFlc6JRFobk4EcqnWc0kz6aJ6p3SRGymscX/0+UaS/KyyPKSTIVrAaY8= lemon@silver" ];
      };
      monitor = {
        description = "Monitor";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKnHEuvbz6ShItc0fik42zGdpo3DkgVWRwy+XBOWKAthibCRX4TgTYJtT5Fao207H/DStJjOrgrhWnqQS4Pxd2JZgFkATajv2j5xGrFC+zA3LAGXjCEkGyzBQGHc/Z6lwuCKsUdCdX51MxaXjyOvzQ6/N/xZEJilPGT1eF83Qr/msAyUJTsKpgnoyugfpiS6tlFm1t9czz16X24d62lTEp8e91+lNNUNCBhzApN8qBOKX1ubjmRDn7N1rbsMxINAi734Lmw8WTe/XfYAMIcWdaRG2c+8zEjcopAdorCPFoajU1mfc5yTTLEfFLuwwqelTUtomuTVVXicG1tj8nh9veTXJlhHl86SrFiVPF8WfMvI38cWrZM8wag/kOGYEi8JM83DzikHavp4YcKgrJCuo8/Cyt7OSKCPrxIwmKh5uUiU5y0L++sMRgdwOOPmVKSV2cBcTaV62O/B3OnrveFHRFsGgMxmrLSSbWVyn0gQ+ulubZP1sGZ0eJlp9lJ3ix7HE= monitor@silver" ];
      };
    };
  };

  # Packages
  environment = {
    systemPackages = with pkgs; [
      dash bash nano unzip unrar p7zip curl wget git gvfs psmisc
      htop sysstat iotop stress nvtop-nvidia netcat lm_sensors
      networkmanager ethtool
      exa trashy
      virt-manager OVMF pciutils virtiofsd libvirt
    ];
    binsh = "${pkgs.dash}/bin/dash";
    shells = with pkgs; [ bash ];
    etc = let
      json = pkgs.formats.json {};
    in {
      "pipewire/pipewire.d/92-low-latency.conf".source = json.generate "92-low-latency.conf" {
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 48;
          default.clock.min-quantum = 48;
          default.clock.max-quantum = 48;
        };
      };
      "pipewire/pipewire-pulse.d/92-low-latency.conf".source = json.generate "92-low-latency.conf" {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = "48/48000";
              pulse.default.req = "48/48000";
              pulse.max.req = "48/48000";
              pulse.min.quantum = "48/48000";
              pulse.max.quantum = "48/48000";
            };
          }
        ];
        stream.properties = {
          node.latency = "48/48000";
          resample.quality = 1;
        };
      };
    };
  };

  # Configs
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
      };
      extraConfig = ''
        AllowTcpForwarding yes
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };
    sysstat.enable = true;
  };
  virtualisation = {
    containerd.enable = true;
    docker = { 
      enable = true;
      enableNvidia = true;
      liveRestore = false;
      daemon.settings = {
        containerd = "/run/containerd/containerd.sock";
        containerd-namespace = "docker";
        features = {
          experimental = true;
          containerd-snapshotter = true;
        };
      };
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
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };
  };
  nixpkgs.config = {
    permittedInsecurePackages = [
      "openssl-1.1.1u"
      "nodejs-16.20.0"
      "python-2.7.18.6"
      "electron-19.0.7"
    ];
  };

  # Drives
  # Home (1 TB Sabrent)
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/30266ca4-5926-430a-83f5-403c30092cf5";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  # 2 TB Seagate
  fileSystems."/home/HDD2TBEXT4" = {
    device = "/dev/disk/by-uuid/c532ca53-130a-46c6-9e06-3aee4fd8b6e2";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  # 1 TB Toshiba
  fileSystems."/home/BACKUPDRIVE" = {
    device = "/dev/disk/by-uuid/76946991-d872-4936-82f2-298225ea010b";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  system.stateVersion = "23.05";
}
