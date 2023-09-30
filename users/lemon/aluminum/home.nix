{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../../../common/usermodules/customization.nix
    ../../../common/usermodules/dunst.nix
    ../../../common/usermodules/polybar/default.nix
    ../../../common/usermodules/spicetify.nix
  ];

  home = {
    packages = with pkgs; [
      i3lock-fancy-rapid
      firefox pcmanfm gparted pavucontrol
      lite-xl rofi hilbish vscodium github-desktop webcord-vencord
      haruna feh gimp obs-studio authy xarchiver filezilla easytag easyeffects soundux openshot-qt qbittorrent
      exa bat trashy fd ripgrep
      pamixer playerctl appimage-run neofetch ventoy-bin act scrot
      libsForQt5.kruler
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
      ".config/autostart/" = {
        source = ./dots/.config/autostart;
        recursive = true;
      };
      ".config/" = {
        source = ../../../common/dots/.config;
        recursive = true;
      ".vscode-oss/" = {
        source = ../../../common/dots/.vscode-oss;
        recursive = true;
      };
      ".xinitrc" = {
        source = ../../../common/dots/.xinitrc;
      };
    };
    stateVersion = "to be added";
  };

  xsession = {
    enable = true;
    windowManager.awesome = {
      enable = true;
      package = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-luajit-git;
    };
  };
  services = {
    flameshot = {
      enable = true;
      settings = {
        General = {
          disabledTrayIcon = true;
        };
      };
    };
  };
  programs.home-manager.enable = true;

  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "pcmanfm.desktop";
      };
    };
    desktopEntries = {
      discord = {
        name = "Discord";
        exec = "webcord -- --add-css-theme=/home/lemon/.config/BetterDiscord/themes/Lemon.theme.css";
        icon = "/home/lemon/.icons/Papirus/32x32/apps/webcord.svg";
        terminal = false;
        type = "Application";
        categories = [ "Application" ];
      };
    };
  };
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
    permittedInsecurePackages = [
      "openssl-1.1.1u"
    ];
  };
}
