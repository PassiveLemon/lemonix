{ lib, ... }: {
  imports = [
    ./modules/cmdline.nix
    ./modules/customization.nix
    ./modules/desktop.nix
    ./modules/mime.nix
    ./modules/programs.nix
  ];

  home = {
    username = "lemon";
    homeDirectory = "/home/lemon";
    # Link everything in common/home to the users home
    file."." = lib.mkForce {
      source = ./home;
      recursive = true;
    };
  };

  xdg.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };
  news.display = "silent";
  manual.manpages.enable = false;
}

