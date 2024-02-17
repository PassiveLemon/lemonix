{ inputs, pkgs, config, lib, ... }: {
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8*1024;
      priority = 50;
      randomEncryption.enable = true;
    } 
  ];
}
