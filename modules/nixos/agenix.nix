{ inputs, system, config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.lemonix.agenix;
in
{
  options = {
    lemonix.agenix = {
      enable = mkEnableOption "agenix";
    };
  };

  imports = [
    inputs.agenix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    environment.systemPackages = [
      inputs.agenix.packages.${system}.default
    ];
    lemonix.ssh.enable = true;
  };
}

