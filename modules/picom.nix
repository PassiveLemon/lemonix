{ config, pkgs, ... }: {
  services.picom = {
    enable = true;
    package = pkgs.picom-next;
    settings = {
      # Shadows
      shadow = true;
      shadow-radius = 11;
      shadow-opacity = 0.75;
      shadow-offset-x = -7;
      shadow-offset-y = -7;
      shadow-exlude = [
        "window_type = 'desktop'"
        "window_type = 'dock'"
        "class_g = 'Polybar'"
        "class_g = 'firefox' && argb"
      ];
      # Fading
      fading = true;
      fade-in-step = 0.1;
      fade-out-step = 0.1;
      # Corners
      corner-radius = 0;
      round-borders = 1;
      rounded-corners-exclude = [
        "window_type = 'desktop'"
        "window_type = 'dock'"
        "class_g = 'Polybar'"
        "class_g = 'dunst'"
        "class_g = 'firefox' && argb"
      ];
      # Blur
      blur = {
        method = "dual_kawase";
        strength = 3;
      };
      blur-kern = "3x3box";
      blur-background-exclude = [
        "window_type = 'desktop'"
        "class_g = 'firefox' && argb"
        "_GTK_FRAME_EXTENTS@:c"
      ];
      # Other
      daemon = true;
      backend = "glx";
      vsync = true;
      use-damage = true;
      log-level = "warn";
      xrender-sync-fence = true;
      mark-wmwin-focused = true;
      mark-ovredir-focused = false;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      wintypes = {
        tooltip = { fade = true; };
        dock = { shadow = true; };
        dnd = { shadow = true; };
        popup_menu = { opacity = 1; };
        dropdown_menu = { opacity = 0.8; };
      };
    };
  };
}
