{ ... }: {
  # Titanium is headless, home-manager is only used to link some CLI config files
  imports = [
    ../common/modules/cmdline.nix
  ];

  home = {
    username = "lemon";
    homeDirectory = "/home/lemon";
    stateVersion = "26.11"; # Don't change unless you know what you are doing
  };

  xdg.configFile."." = {
    source = ../common/home/.config;
    recursive = true;
  };

  news.display = "silent";
  manual.manpages.enable = false;
}

