{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
#  virtualisation.vmware.guest.enable = true;
}