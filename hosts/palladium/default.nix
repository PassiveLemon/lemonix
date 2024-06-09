{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ./modules/docker.nix
    ./modules/borg.nix
  ];

  lemonix = {
    ssh.enable = true;
  };
}
