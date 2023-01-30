{ config, pkgs, ... }: {
  services.dunst.settings = {
    global = {
      origin = "bottom-right";
      width = 300;
      height = 180;
      offset = "12x12";
      foreground = "#abb2bf";
      background = "#282c34";
      transparency = 20;
      frame_color = "#d7dae0";
      frame_width = 2;
      font = "Fira Code Nerd Font 12";
    };
    urgency_critical = {
      frame_color = "#e05561";
      timeout = 10;
    };
  };
}