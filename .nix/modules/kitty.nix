{ config, pkgs, colors, ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.8";
      window_padding_width = "6 6";
      font_family = "Fira Code Medium Nerd Font Complete";
      font_size = 10;
      enable_audio_bell = "no";
      url_color = "#4892cb";
      shell = "hilbish";

      foreground = "#b5b5b5";
      background = "#232426";

      # black
      color0 = "#31343a";
      color8 = "#40454f";
      # red
      color1 = "#f35252";
      color9 = "#f35279";
      # green
      color2 = "#81cc52";
      color10 = "#81cc52";
      # yellow
      color3 = "#f38c52";
      color11 = "#f3d052";
      # blue
      color4 = "#47a6dc";
      color12 = "#47a6dc";
      # magenta
      color5 = "#926ae5";
      color13 = "#926ae5";
      # cyan
      color6 = "#75dad4";
      color14 = "#75dad4";
      # white
      color7 = "#bdc4d3";
      color15 = "#e6e6e6";
    };
  };
}