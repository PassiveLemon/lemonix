{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
#  virtualisation.vmware.guest.enable = true;
}