{ config, pkgs, lib, ... }:

let
  cfg = config.services.steamvr;
  inherit (lib) mkIf mkEnableOption mkPackageOption mkOption mdDoc literalExpression types maintainers;
in
{
  options = {
    services.steamvr = {
      runtimeOverride = {
        enable = mkEnableOption "a runtime override for SteamVR";

        path = mkOption {
          type = types.path;
          description = mdDoc "The path within the runtime package. `pkgs.steam` will use the default steam runtime.";
          default = "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/SteamVR";
          example = literalExpression "${pkgs.opencomposite}/lib/opencomposite";
        };
      };
      activeRuntimeOverride = {
        enable = mkEnableOption "a override for active_runtime.json";

        path = mkOption {
          type = types.path;
          description = mdDoc "The active_runtime.json path to symlink to `XDG_CONFIG_HOME/openxr/1/active_runtime.json`";
          example = literalExpression "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
        };
      };
    };
  };

  config = mkIf cfg.runtimeOverride.enable {
    xdg.configFile = {
      "openvr/openvrpaths.vrpath" = mkIf cfg.runtimeOverride.enable {
        text = ''
          {
            "config" : 
            [
              "${config.home.homeDirectory}/.local/share/Steam/config"
            ],
            "external_drivers" : null,
            "jsonid" : "vrpathreg",
            "log" : 
            [
              "${config.home.homeDirectory}/.local/share/Steam/logs"
            ],
            "runtime" : 
            [
              "${cfg.runtimeOverride.path}"
            ],
            "version" : 1
          }
        '';
      };
      "openxr/1/active_runtime.json" = mkIf cfg.activeRuntimeOverride.enable {
        source = cfg.activeRuntimeOverride.path;
      };
    };
  };
  meta.maintainers = with maintainers; [ passivelemon ];
}
