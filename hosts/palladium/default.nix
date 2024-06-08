{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./system.nix
    ../../modules/nixos/ssh.nix
    ./modules/docker.nix
    ./modules/borg.nix
  ];
}
