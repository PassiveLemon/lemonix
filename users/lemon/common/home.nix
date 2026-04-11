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
      # File/storage management
      pcmanfm xarchiver localsend filezilla
      gparted ffmpegthumbnailer
      # Development
      github-desktop
      shellcheck luajitPackages.luacheck python312Packages.flake8
      nil nimlsp pyright lua-language-server bash-language-server dockerfile-language-server yaml-language-server
      # Office
      obsidian drawio
      onlyoffice-desktopeditors onlyoffice-documentserver
      # Audio
      pwvucontrol crosspipe
      feishin
      # Easyeffects crashes on versions 8.1.2+: https://github.com/wwmm/easyeffects/issues/4978
      (easyeffects.overrideAttrs {
        version = "8.1.1";
        src = fetchFromGitHub {
          owner = "wwmm";
          repo = "easyeffects";
          tag = "v8.1.1";
          hash = "sha256-+CH7AoAX4fdjtwnVjWWLB7IKTD3cunbBjVlurrHJgGU=";
        };
      })
      # Image/Video
      loupe flameshot papers gimp drawy
      mpv kdePackages.kdenlive
      # Miscellaneous
      ente-auth xclicker
      # School
      scilab-bin ltspice
    ];
    username = "lemon";
    homeDirectory = "/home/lemon";
    file = {
      ".config/" = {
        source = ./home/.config;
        recursive = true;
      };
      ".local/" = {
        source = ./home/.local;
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

