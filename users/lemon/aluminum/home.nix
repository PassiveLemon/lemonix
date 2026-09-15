{ ... }: {
  imports = [
    ../common/home.nix
    ./modules/customization.nix
    ./modules/desktop.nix
  ];

  home.stateVersion = "26.05"; # Don't change unless you know what you are doing

  xdg.configFile = {
    "." = {
      source = ./home/.config;
      recursive = true;
    };
  };

  nixpkgs.config.permittedInsecurePackages = [ ];
}

