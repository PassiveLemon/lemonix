{ ... }: {
  lemonix = {
    system = {
      mobile.enable = true;
      hibernation.enable = true;
      specs = {
        cpu = 12;
        gpu = "amd-igpu";
        memory = 16;
      };
    };
    lanzaboote.enable = true;
    bluetooth.enable = true;
    gaming = {
      enable = true;
      desktop.enable = true;
    };
    swap = {
      enable = true;
      device = "/dev/nvme0n1p5";
    };
  };
}

