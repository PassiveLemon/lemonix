{ config, pkgs, lib, ... }:

let
  cfg = config.services.steamvr;
  inherit (lib) mkIf mkEnableOption mkPackageOption mkOption mdDoc literalExpression types maintainers;

  runtimePackage = cfg.runtimeOverride.package;
  runtimePackageSubPath = cfg.runtimeOverride.packageSubPath;

  runtimePackageCat = if runtimePackage == pkgs.steam
  then "${config.home.profileDirectory}/.local/share/Steam/steamapps/common/SteamVR"
  else "${runtimePackage}${runtimePackageSubPath}";
in
{
  options = {
    services.steamvr = {
      runtimeOverride = {
        enable = mkEnableOption "a runtime override for SteamVR";

        package = mkPackageOption pkgs "steam" {
          extraDescription = mdDoc "`pkgs.steam` will use the default steam runtime.";
          example = literalExpression "pkgs.opencomposite";
        };

        packageSubPath = mkOption {
          type = types.str;
          description = mdDoc "The path within the runtime package.";
          example = literalExpression "/lib/opencomposite";
        };
      };
    };
  };

  config = mkIf cfg.runtimeOverride.enable {

    home.packages = [ cfg.runtimeOverride.package ];

    xdg.configFile = mkIf cfg.runtimeOverride.enable {
      "openvr/openvrpaths.vrpath".text = ''
        {
          "config" : 
          [
            "${config.home.profileDirectory}/.local/share/Steam/config"
          ],
          "external_drivers" : null,
          "jsonid" : "vrpathreg",
          "log" : 
          [
            "${config.home.profileDirectory}/.local/share/Steam/logs"
          ],
          "runtime" : 
          [
            "${runtimePackageCat}"
          ],
          "version" : 1
        }
      '';
    };
  };
  meta.maintainers = with maintainers; [ passivelemon ];
}
