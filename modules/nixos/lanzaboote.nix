{ inputs, config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkForce;
  cfg = config.lemonix.lanzaboote;
in
{
  options = {
    lemonix.lanzaboote = {
      enable = mkEnableOption "lanzaboote";
    };
  };

  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sbctl
    ];

    boot = {
      loader = {
        systemd-boot.enable = mkForce false;
        grub.enable = mkForce false;
      };
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    };
  };
}

