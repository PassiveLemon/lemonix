{ config, pkgs, ... }:

{
    imports = [
        ./hardware-configuration.nix
        /home/lemon/.nix/system.nix
        /home/lemon/.nix/utility.nix
        /home/lemon/.nix/program.nix
        /home/lemon/.nix/customization.nix
    ];

    nixpkgs.config.allowUnfree = true;

    sound.enable = true;
    hardware.pulseaudio.enable = true;

    system.stateVersion = "22.11";
}