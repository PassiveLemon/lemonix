{ inputs, pkgs, config, lib, ... }: {
  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100;
  };
}
