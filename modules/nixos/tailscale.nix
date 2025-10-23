{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.lemonix.tailscale;
in
{
  options = {
    lemonix.tailscale = {
      enable = mkEnableOption "tailscale";
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = config.lemonix.agenix.enable;
      message = "lemonix: Agenix must be enabled to enable tailscale.";
    }];

    age.secrets = {
      tailscaleAuthKey = {
        file = ../../secrets/tailscaleAuthKey.age;
        mode = "600";
        owner = "root";
        group = "root";
      };
    };

    services.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscaleAuthKey.path;
      extraUpFlags = [
        "--accept-routes"
        "--operator=lemon"
      ];
    };
  };
}

