{ inputs, config, lib, ... }:
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
    boot = {
      loader = {
        systemd-boot.enable = mkForce false;
        grub.enable = mkForce false;
      };
      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
  };
}

