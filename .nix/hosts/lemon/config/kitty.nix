{ config, pkgs, ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.8";
      window_padding_width = "6 6";
      font_family = "Fira Code Medium Nerd Font Complete";
      font_size = 10;
      enable_audio_bell = "no";
      url_color = "#4892cb";
      foreground = "#abb2bf";
      background = "#282c34";

      #: black
      color0 = "#3f4451";
      color8 = "#4f5666";
      #: red
      color1 = "#e05561";
      color9 = "#ff616e";
      #: green
      color2 = "#8cc265";
      color10 = "#a5e075";
      #: yellow
      color3 = "#d18f52";
      color11 = "#f0a45d";
      #: blue
      color4 = "#4aa5f0";
      color12 = "#4dc4ff";
      #: magenta
      color5 = "#c162de";
      color13 = "#de73ff";
      #: cyan
      color6 = "#42b3c2";
      color14 = "#4cd1e0";
      #: white
      color7 = "#d7dae0";
      color15 = "#e6e6e6";
    };
  };
}