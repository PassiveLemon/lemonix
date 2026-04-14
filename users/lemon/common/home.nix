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
      # File/storage
      pcmanfm xarchiver localsend
      gparted
      ffmpegthumbnailer # https://github.com/NixOS/nixpkgs/pull/509742
      # Office/Development
      obsidian drawio github-desktop
      onlyoffice-desktopeditors onlyoffice-documentserver
      # Audio
      pwvucontrol crosspipe
      feishin
      # Image/Video
      loupe flameshot papers gimp drawy
      mpv kdePackages.kdenlive
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

