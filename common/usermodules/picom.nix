{ inputs, outputs, pkgs, config, lib, ... }: {
  nixpkgs.overlays = [ (final: prev: {
    picom = inputs.nixpkgs-f2k.packages.${pkgs.system}.picom-pijulius;
  }) ];

  services.picom = {
    enable = true;
    settings = {
      # Shadows
      shadow = true;
      shadow-radius = 11;
      shadow-opacity = 0.85;
      shadow-offset-x = -7;
      shadow-offset-y = -7;
      shadow-exlude = [
        "window_type = 'desktop'"
        "window_type = 'dock'"
        "class_g = 'firefox' && window_type = 'popup_menu'"
        "class_g = 'firefox' && argb"
      ];

      # Fading
      fading = true;
      fade-in-step = 0.12;
      fade-out-step = 0.12;

      # Corners
      corner-radius = 0;

      # Blur
      #blur-method = "dual_kawase";
      #blur-strength = 3;
      #blur-kern = "3x3box";
      blur-background-exclude = [
        "class_g != 'kitty' &&
        window_type != 'tooltip' &&
        window_type != 'menu' &&
        window_type != 'popup_menu' &&
        window_type != 'dropdown_menu' &&
        window_type != 'splash' &&
        window_type != 'combo'"
        "window_type = 'desktop'"
        "window_type = 'dock'"
        "class_g = 'firefox' && window_type = 'popup_menu'"
        "class_g = 'firefox' && argb"
        "_NET_WM_WINDOW_TYPE:a = '_NET_WM_WINDOW_TYPE_NOTIFICATION'"
        "_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
        "_GTK_FRAME_EXTENTS@:c"
      ];

      # Other
      daemon = true;
      backend = "xrender";
      vsync = false;
      use-damage = true;
      log-level = "INFO";
      xrender-sync-fence = true;
      mark-wmwin-focused = true;
      mark-ovredir-focused = false;
      unredir-if-possible = true;
      wintypes = {
        tooltip = { fade = false; };
        dock = {
          shadow = true;
          clip-shadow-above = true;
        };
        dnd = { shadow = true; };
        popup_menu = { opacity = 1; };
        dropdown_menu = { opacity = 1; };
        utility = { shadow = false; };
      };
      
      # Animations
      animations = true;
      animation-for-transient-window = "zoom";
      animation-for-open-window = "zoom";
      animation-for-unmap-window = "zoom";
      animation-for-workspace-switch-in = "slide-right";
      animation-for-workspace-switch-out = "slide-left";
      animation-stiffness = 400;
      animation-dampening = 20;
      animation-window-mass = 0.5;
      animation-delta = 8;
      animation-clamping = true;
    };
  };
}
