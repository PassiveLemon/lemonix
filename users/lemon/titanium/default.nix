{ ... }: { 
  # Titanium is headless, home-manager is only used to link some CLI config files
  imports = [
    # ../common
    ../../../overlays
    ./home.nix
  ];
}

