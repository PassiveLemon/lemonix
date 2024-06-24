{ config, pkgs, lib, ... }:
let
  inherit (lib) mkAliasOptionModule mkIf mkEnableOption mkPackageOption mkOption mkDefault optionalString getExe' maintainers;
  cfg = config.services.wivrn;
  configFormat = pkgs.formats.json { };
  configFile = configFormat.generate "config.json" cfg.config.json;
in
{
  options = {
    services.wivrn = {
      enable = mkEnableOption "WiVRn, an OpenXR streaming application";

      package = mkPackageOption pkgs "wivrn" { };

      openFirewall = mkEnableOption "the default ports in the firewall for the WiVRn server";

      defaultRuntime = mkEnableOption ''
        WiVRn Monado as the default OpenXR runtime on the system. The config can be found at `/etc/xdg/openxr/1/active_runtime.json`.

        Note that applications can bypass this option by setting an active
        runtime in a writable XDG_CONFIG_DIRS location like `~/.config`
      '' // { default = true; };

      highPriority = mkEnableOption "high priority capability for wivrn-server" // { default = true; };

      config = {
        enable = mkEnableOption "configuration for WiVRn";
        json = mkOption {
          type = configFormat.type;
          description = ''
            Configuration for WiVRn. The attributes are serialized to JSON in config.json.
            See https://github.com/Meumeu/WiVRn/blob/master/docs/configuration.md
          '';
          default = { };
          example = {
            scale = 1.0;
            bitrate = 100000000;
            encoders = [
              {
                encoder = "nvenc";
                codec = "h264";
                width = 0.5;
                height = 1.0;
                offset_x = 0.0;
                offset_y = 0.0;
              }
              {
                encoder = "nvenc";
                codec = "h264";
                width = 0.5;
                height = 1.0;
                offset_x = 0.5;
                offset_y = 0.0;
              }
            ];
          };
        };
      };
    };
  };

  imports = [
    (mkAliasOptionModule [ "services" "wivrn" "monadoEnvironment" ] [ "systemd" "user" "services" "wivrn" "environment" ])
  ];

  config = mkIf cfg.enable {
    security.wrappers."wivrn-server" = mkIf cfg.highPriority {
      setuid = false;
      owner = "root";
      group = "root";
      # cap_sys_nice needed for asynchronous reprojection
      capabilities = "cap_sys_nice+eip";
      source = getExe' cfg.package "wivrn-server";
    };

    systemd.user = {
      services.wivrn = {
        description = "WiVRn XR runtime service module";
        unitConfig.ConditionUser = "!root";
        serviceConfig = {
          ExecStart = (
            if cfg.highPriority
            then"${config.security.wrapperDir}/wivrn-server"
            else getExe' cfg.package "wivrn-server"
          ) + optionalString cfg.config.enable " -f ${configFile}";
          Restart = "no";
          # Hardening options
          BindPaths = [
            "/run/user/%U"
            "%h/.config/wivrn"
          ];
          CapabilityBoundingSet = [
            "CAP_SETPCAP"
            "CAP_SYS_ADMIN"
            "CAP_SYS_NICE"
          ];
          KeyringMode = "private";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          PrivateTmp = true;
          ProcSubset = "pid";
          ProtectControlGroups = true;
          ProtectClock = true;
          ProtectHome = "tmpfs";
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RestrictAddressFamilies= [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
        };
        restartTriggers = [
          cfg.package
          configFile
        ];
      };
    };

    services = {
      wivrn.monadoEnvironment = {
        # Default options
        # https://gitlab.freedesktop.org/monado/monado/-/blob/4548e1738591d0904f8db4df8ede652ece889a76/src/xrt/targets/service/monado.in.service#L12
        XRT_COMPOSITOR_LOG = mkDefault "debug";
        XRT_PRINT_OPTIONS = mkDefault "on";
        IPC_EXIT_ON_DISCONNECT = mkDefault "off";
      };
      udev.packages = with pkgs; [
        android-udev-rules
        xr-hardware # WiVRn can be used with some wired headsets
      ];
      avahi = {
        enable = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 9757 ];
      allowedUDPPorts = [ 9757 ];
    };

    environment = {
      systemPackages = [ cfg.package ];
      pathsToLink = [ "/share/openxr" ];
      etc."xdg/openxr/1/active_runtime.json" = mkIf cfg.defaultRuntime {
        source = "${cfg.package}/share/openxr/1/openxr_wivrn.json";
      };
    };
  };
  meta.maintainers = with maintainers; [ passivelemon ];
}
