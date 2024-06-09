{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../../modules/nixos/lanzaboote.nix
  ];

  lemonix = {
    bluetooth.enable = true;
    gaming = {
      enable = true;
      vr.enable = true;
    };
  };
}
