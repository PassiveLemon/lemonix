{ config, ... }: {
  imports = [
    ./entrypoint.nix
    ./middleware.nix
    ./routers.nix
  ];

  users = {
    # User and group are created by the traefik module
    groups."traefik".gid = 1205;
    users."traefik" = {
      uid = 1105;
      extraGroups = [ "docker" ];
    };
  };

  age.secrets."traefikCFToken.env" = {
    file = ../../../../secrets/traefikCFToken.env.age;
    mode = "600";
    owner = "traefik";
    group = "traefik";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  
  services.traefik = {
    enable = true;
    environmentFiles = [
      config.age.secrets."traefikCFToken.env".path
    ];
    staticConfigOptions = {
      api = {
        dashboard = true;
        insecure = true;
      };
      log = {
        filePath = "${config.services.traefik.dataDir}/traefik.log";
        level = "INFO";
      };
      accessLog = {
        filePath = "${config.services.traefik.dataDir}/access.log";
        format = "json";
        filters.statusCodes = [ "400-599" ];
        bufferingSize = "0";
        fields.headers = {
          defaultMode = "drop";
          names.User-Agent = "keep";
        };
      };
      providers.docker = {
        endpoint = "unix:///var/run/docker.sock";
        exposedByDefault = false;
        network = "traefik-priv";
      };
    };
  };
}

