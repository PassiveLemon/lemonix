{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./system.nix
    ../../modules/nixos/lanzaboote.nix

    ./user.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/gaming/desktop.nix
  ];
}
