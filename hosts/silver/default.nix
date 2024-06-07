{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./system.nix
    ../../modules/nixos/swap.nix
    ../../modules/nixos/ssh.nix
    ./modules/docker.nix
    ./modules/borg.nix

    ./user.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/gaming/desktop.nix
    ../../modules/nixos/gaming/vr.nix
  ];
}
