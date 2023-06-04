{ config, pkgs, colors, ... }: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    settings = {
      background_opacity = "0.85";
      window_padding_width = "5 6 5 6";
      font_family = "Fira Code Medium Nerd Font Complete";
      font_size = 10;
      enable_audio_bell = "no";
      update_check_interval = 0;
      url_color = "#4892cb";
      shell = "hilbish";

      foreground = "#aaaaaa";
      background = "#222222";

      # black
      color0 = "#31343a";
      color8 = "#40454f";
      # red
      color1 = "#e06c75";
      color9 = "#e06c75";
      # green
      color2 = "#98c379";
      color10 = "#98c379";
      # yellow
      color3 = "#e5c07b";
      color11 = "#e5c07b";
      # blue
      color4 = "#61afef";
      color12 = "#61afef";
      # magenta
      color5 = "#c678dd";
      color13 = "#c678dd";
      # cyan
      color6 = "#56b6c2";
      color14 = "#56b6c2";
      # white
      color7 = "#aaaaaa";
      color15 = "#d4d4d4";
    };
  };
}