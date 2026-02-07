{ inputs, outputs, pkgs, ... }: {
  imports = [
    ./modules/customization.nix
    ./modules/desktop.nix
    ./modules/mime.nix
    ./modules/programs.nix
  ];

  home = {
    packages = with pkgs; [
      # Terminal
      tym hilbish comma fend
      nh eza bat trashy pamixer imagemagick
      # nix-output-monitor dix
      # File/storage management
      pcmanfm xarchiver gparted filezilla
      ffmpegthumbnailer
      # Development
      github-desktop
      shellcheck luajitPackages.luacheck python312Packages.flake8
      nil nimlsp pyright lua-language-server bash-language-server dockerfile-language-server yaml-language-server
      # Office
      obsidian onlyoffice-desktopeditors onlyoffice-documentserver drawio
      # Audio
      feishin
      pwvucontrol easyeffects helvum
      # Image/Video
      loupe flameshot papers gimp scrot
      mpv kdePackages.kdenlive
      # Miscellaneous
      picom ente-auth localsend xclicker
      # School
      R scilab-bin
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
      ".config/" = {
        source = ./home/.config;
        recursive = true;
      };
      ".vscode/" = {
        source = ./home/.vscode;
        recursive = true;
      };
      "Documents/" = {
        source = ./home/Documents;
        recursive = true;
      };
    };
  };

  xdg = {
    enable = true;
    dataFile = {
      "hilbish/libs/promptua" = {
        source = inputs.hilbish-promptua;
      };
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
    overlays = [
      outputs.overlays.packages
    ];
  };

  news.display = "silent";
  manual.manpages.enable = false;
}

