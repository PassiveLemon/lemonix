{ config, pkgs, colors, ... }: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    settings = {
      background_opacity = "0.85";
      window_padding_width = "5 6 5 6";
      font_family = "FiraCode Nerd Font Ret";
      font_size = 10;
      enable_audio_bell = "no";
      update_check_interval = 0;
      url_color = "#61b8ff";
      shell = "hilbish";

      foreground = "#aaaaaa";
      background = "#222222";

      # black
      color0 = "#31343a";
      color8 = "#40454f";
      # red
      color1 = "#f05d6b";
      color9 = "#f05d6b";
      # green
      color2 = "#93cb6b";
      color10 = "#93cb6b";
      # yellow
      color3 = "#eac56f";
      color11 = "#eac56f";
      # blue
      color4 = "#61b8ff";
      color12 = "#61b8ff";
      # magenta
      color5 = "#cd61ec";
      color13 = "#cd61ec";
      # cyan
      color6 = "#53d2e0";
      color14 = "#53d2e0";
      # white
      color7 = "#c6c6c6";
      color15 = "#e2e2e2";
    };
  };
}
