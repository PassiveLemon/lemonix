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
    agenix.enable = true;
    lanzaboote.enable = true;
    bluetooth.enable = true;
    gaming = {
      enable = true;
      desktop.enable = true;
    };
    ssh = {
      enable = true;
      openFirewall = false;
    };
    swap = {
      enable = true;
      device = "/dev/nvme0n1p5";
    };
  };
}

