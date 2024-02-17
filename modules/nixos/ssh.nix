{ inputs, pkgs, config, lib, ... }: {
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };
  services = {
    openssh = {
      enable = true;
      extraConfig = ''
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AllowTcpForwarding yes
        AuthenticationMethods publickey
        ChallengeResponseAuthentication no
        KbdInteractiveAuthentication no
        PasswordAuthentication no
        PermitEmptyPasswords no
        PermitRootLogin no
        X11Forwarding no
      '';
    };
  };
}
