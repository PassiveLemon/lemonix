{ config, pkgs, colors, ... }: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    settings = {
      background_opacity = "0.85";
      window_padding_width = "5 6 5 6";

      enable_audio_bell = "no";
      confirm_os_window_close = 0;
      update_check_interval = 0;
      shell = "hilbish";

      font_family = "FiraCode Nerd Font Mono Ret";
      font_size = 10;
      font_features = "none";
      disable_ligatures = "always";

      foreground = "#aaaaaa";
      background = "#222222";

      url_color = "#61b8ff";

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
