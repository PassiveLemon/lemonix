{ ... }: {
  imports = [
    ../common/home.nix
    ./modules/customization.nix
    ./modules/desktop.nix
  ];

  home.stateVersion = "26.05"; # Don't change unless you know what you are doing

<<<<<<< HEAD
  xdg.configFile = {
    "." = {
      source = ./home/.config;
      recursive = true;
    };
  };

  nixpkgs.config.permittedInsecurePackages = [ ];
=======
  xdg = {
    configFile = {
      "." = {
        source = ./home/.config;
        recursive = true;
      };
    };
  };

  nixpkgs = {
    config.permittedInsecurePackages = [
    ];
  };
>>>>>>> 95b9d1ad (feature: somewm)
}

