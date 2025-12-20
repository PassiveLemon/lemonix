{ inputs, lib, pkgs, ... }: {
  imports = [
    inputs.lemonake.nixosModules.somewm
  ];

  environment = {
    systemPackages = with pkgs; [
      xss-lock gtk3 snixembed
      networkmanagerapplet trayscale
      resources baobab
    ];
  };

  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      displayManager = {
        startx.enable = true;
      };
    };
    libinput = {
      enable = true;
      mouse = {
        middleEmulation = false;
        accelProfile = "flat";
        accelSpeed = "-0.5";
      };
      touchpad = {
        buttonMapping = "1 1 3 4 5 6 7";
        middleEmulation = false;
        accelProfile = "flat";
        naturalScrolling = true;
        additionalOptions = ''
          Option "ScrollPixelDistance" "50"
        '';
      };
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    gnome.gnome-keyring.enable = true;
    flatpak.enable = true;
  };

  programs = {
    somewm = let
      somewm = (inputs.lemonake.packages.${pkgs.system}.somewm-git.override {
        additionalLuaPackages = [
          pkgs.luajitPackages.luafilesystem
        ];
        additionalLuaCPATH = "${inputs.lemonake.packages.${pkgs.system}.lua-pam-git}/lib/?.so";
      }).overrideAttrs {
        GI_TYPELIB_PATH = let
          mkTypeLibPath = pkg: "${pkg}/lib/girepository-1.0";
          extraGITypeLibPaths = lib.forEach (with pkgs; [
            networkmanager upower
          ] ++ (with pkgs.astal; [
            auth battery bluetooth mpris network powerprofiles wireplumber
          ])) mkTypeLibPath;
        in
        lib.concatStringsSep ":" (extraGITypeLibPaths ++ [ (mkTypeLibPath pkgs.pango.out) ]);
      };
    in {
      enable = true;
      package = somewm;
    };
    dconf.enable = true;
    seahorse.enable = true;
  };

  environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libvdpau-va-gl
      ];
    };
  };

  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
      config.common.default = [ "gtk" ];
      extraPortals = with pkgs; [
        gnome-keyring
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };
  };
}

