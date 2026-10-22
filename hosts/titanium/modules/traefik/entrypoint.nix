{ config, ... }: {
  services.traefik.staticConfigOptions = {
    certificatesResolvers = {
      cf-dns-cha.acme = {
        email = "lemonl3mn@protonmail.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        caServer = "https://acme-v02.api.letsencrypt.org/directory"; # Production
        # caServer = "https://acme-staging-v02.api.letsencrypt.org/directory"; # Staging
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = [ "1.1.1.1:53" "1.0.0.1:53" ];
        };
      };
      # http-cha.acme = {
      #   email = "lemonl3mn@protonmail.com";
      #   storage = "${config.services.traefik.dataDir}/acme.json";
      #   caServer = "https://acme-v02.api.letsencrypt.org/directory"; # Production
      #   # caServer = "https://acme-staging-v02.api.letsencrypt.org/directory"; # Staging
      #   httpChallenge.entryPoint = "http";
      # };
    };
    entryPoints = {
      http = {
        address = ":80/tcp";
        http = {
          redirections.entryPoint = {
            scheme = "https";
            to = "https";
            permanent = true;
          };
          aliasHeadersStrategy = "delete";
        };
        forwardedHeaders.trustedIPs = [ "127.0.0.1/32" "192.168.1.1/24" ];
      };
      https = {
        address = ":443/tcp";
        http = {
          tls = {
            certResolver = "cf-dns-cha";
            domains = [
              {
                main = "passivelemon.net";
                sans = [ "*.passivelemon.net" ];
              }
              {
                main = "passivelemon.com";
                sans = [ "*.passivelemon.com" ];
              }
            ];
          };
          aliasHeadersStrategy = "delete";
        };
        forwardedHeaders.trustedIPs = [ "127.0.0.1/32" "192.168.1.1/24" ];
      };
    };
    tls.options.default = {
      minVersion = "VersionTLS12";
      cipherSuites = [
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
        "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
        "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305"
      ];
    };
  };
}

