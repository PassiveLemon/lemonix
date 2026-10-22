{ ... }: {
  services.traefik.dynamicConfigOptions = {
    http.middlewares = {
      ipallow-public.ipAllowList.sourceRange = [
        "127.0.0.1/32"
        "192.168.1.1/24"
        "10.0.0.0/8"
        "100.64.0.1/24"
        # "" # Whatever future public IP address
      ];
      ipallow-tailscale.ipAllowList.sourceRange = [
        "127.0.0.1/32"
        "192.168.1.1/24"
        "10.0.0.0/8"
        "100.64.0.1/24"
      ];
      ipallow-private.ipAllowList.sourceRange = [
        "127.0.0.1/32"
        "192.168.1.1/24"
      ];
      basic-auth.basicAuth.users = [ "user:$apr1$f/vkx.0a$wdtm7Zgfphk72dvrvlpF20" ];
      github-io.redirectRegex = {
        regex = "^https?://(www\.)?passivelemon\.com(.*)$";
        replacement = "https://passivelemon.github.io\${2}";
        permanent = true;
      };
    };
  };
}

