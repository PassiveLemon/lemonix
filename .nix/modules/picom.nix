{ config, pkgs, ... }: {
  services.picom = {
    enable = true;
    package = pkgs.unstable.picom-next;
    settings = {
      # Shadows
      shadow = true;
      shadow-radius = 11;
      shadow-opacity = 0.75;
      shadow-offset-x = -7;
      shadow-offset-y = -7;
      shadow-exlude = [
        "class_g = 'Polybar'"
      ];
      # Fading
      fading = true;
      fade-in-step = 0.08;
      fade-out-step = 0.08;
      # Corners
      corner-radius = 7;
      round-borders = 1;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'Desktop'"
        "class_g = 'Polybar'"
        "class_g = 'dunst'"
      ];
      # Blur
      blur = {
        method = "dual_kawase";
        strength = 3;
      };
      blur-kern = "3x3box";
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'Desktop'"
        "_GTK_FRAME_EXTENTS@:c"
      ];
      # Other
      daemon = true;
      backend = "glx";
      vsync = false;
      use-damage = true;
      refresh-rate = 144;
      log-level = "warn";
      xrender-sync-fence = true;
      mark-wmwin-focused = true;
      mark-ovredir-focused = false;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      wintypes = {
        tooltip = { fade = true; };
        dock = { shadow = false; };
        dnd = { shadow = true; };
        popup_menu = { opacity = 0.8; };
        dropdown_menu = { opacity = 0.8; };
      };
    };
  };
  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz) {
        config = config.nixpkgs.config;
      };
    };
  };
}
