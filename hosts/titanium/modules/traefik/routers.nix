{ ... }: {
  services.traefik.dynamicConfigOptions = {
    http = {
      routers = {
        github-io = {
          rule = "Host(`passivelemon.com`) || Host(`www.passivelemon.com`)";
          entryPoints = "https";
          service = "noop@internal";
          middlewares = "github-io@file";
          tls.certresolver = "cf-dns-cha";
        };
        traefik-https = {
          rule = "Host(`traefik.passivelemon.net`)";
          entrypoints = "https";
          service = "api@internal";
          middlewares = "ipallow-private@file,basic-auth@file";
        };
        nix-serve = {
          rule = "Host(`binarycache.passivelemon.com`)";
          entryPoints = "https";
          service = "nix-serve";
        };
      };
      services = {
        nix-serve.loadBalancer.servers = [{
          url = "http://localhost:5000";
        }];
        api.loadBalancer.servers = [{
          url = "http://localhost:8080";
        }];
      };
    };
  };
}

