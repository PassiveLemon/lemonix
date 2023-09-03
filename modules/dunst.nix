{ config, pkgs, ... }: {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        origin = "bottom-right";
        width = 300;
        height = 180;
        offset = "12x12";
        foreground = "#aaaaaa";
        background = "#222222";
        transparency = 20;
        frame_color = "#535d6c";
        frame_width = 2;
        corner_radius = 0;
        font = "FiraCode Nerd Font Mono Ret 10";
      };
      urgency_critical = {
        frame_color = "#f05d6b";
        timeout = 5;
      };
    };
  };
}
