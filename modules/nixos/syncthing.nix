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
          "silver" = { id = "RJUPLXU-KS7PLLI-6OTXT22-W26HMRO-RXMFJ5G-2KU6FEM-G54HQ4D-LXWRBA4"; };
          "aluminum" = { id = "WX4PLOZ-WXLJR47-BOFKW6F-YLTJHGS-XPCEYUW-D4Y2BDY-I2LXFPU-W7PQ6A3"; };
          "aluminum-windows" = { id = "RGKBMKP-GU5OK3Q-2NTYZSU-ZDQMU2Q-XV6ABUO-TIIEBYL-J5TQJNB-D43QPA5"; };
        };
        folders = {
          "Shared" = {
            path = "/home/lemon/Shared";
            devices = [ "silver" "aluminum" "aluminum-windows" ];
          };
        };
      };
    };
  };
}

