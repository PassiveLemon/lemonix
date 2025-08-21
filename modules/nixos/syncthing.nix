{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.lemonix.syncthing;
in
{
  options = {
    lemonix.syncthing = {
      enable = mkEnableOption "syncthing";
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      dataDir = "/home/lemon";
      configDir = "/home/lemon/.config/syncthing";
      user = "lemon";
      group = "users";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        gui = {
          user = "RI43dPf7R4CcgvvjjF38O";
          password = "wn2gWn1TEqizQroDh@7Je";
        };
        devices = {
          "Silver" = { id = "RJUPLXU-KS7PLLI-6OTXT22-W26HMRO-RXMFJ5G-2KU6FEM-G54HQ4D-LXWRBA4"; };
          "Aluminum" = { id = "ISH2V3D-ITIYVOE-I6FUGCD-6NQT6VQ-5N2ZG3S-HQOEFI5-ZEDAADF-CJ3OIQ7"; };
          "Aluminum-Windows" = { id = "MCLYZ4I-F2NL364-P6T7LPX-6KW4UCH-UHGCAEY-TLBYD3H-C4TQMXE-GJ3UCQ6"; };
        };
        folders = {
          "Shared" = {
            path = "/home/lemon/Shared";
            devices = [ "Silver" "Aluminum" "Aluminum-Windows" ];
          };
        };
      };
    };
  };
}

