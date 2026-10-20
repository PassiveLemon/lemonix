{ ... }: {
  imports = [
    ../common
    ./home.nix
  ];

  lemonix = {
    gaming = {
      enable = true;
      desktop.enable = true;
    };
    development = {
      enable = true;
      circuits.enable = true;
      printing.enable = true;
    };
  };
}

