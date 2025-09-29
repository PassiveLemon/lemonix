{ ... }: {
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        scaling-factor = 1;
        text-scaling-factor = 1;
      };
    };
  };
}

