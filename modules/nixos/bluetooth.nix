{ inputs, outputs, pkgs, config, lib, ... }: {
  services.blueman.enable = true;
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    bluetooth.enable = true;
  };
}
