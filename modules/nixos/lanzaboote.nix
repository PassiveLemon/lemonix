{ inputs, pkgs, config, lib, ... }: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  environment = {
    systemPackages = with pkgs; [
      sbctl
    ];
  };

  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      grub.enable = lib.mkForce false;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
}
