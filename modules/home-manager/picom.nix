{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge;
  cfg = config.lemonix.picom;
in
{
  options = {
    lemonix.picom = {
      enable = mkEnableOption "picom";
      shadows.enable = mkEnableOption "shadows";
      animations.enable = mkEnableOption "animations";
    };
  };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      package = pkgs.old.picom-allusive;
      settings = mkMerge [
        {
          daemon = true;
          backend = "glx";
          vsync = true;
          use-damage = true;
          log-level = "INFO";
          xrender-sync-fence = true;
          mark-wmwin-focused = true;
          mark-ovredir-focused = false;
          unredir-if-possible = true;
          wintypes = {
            tooltip = { fade = false; };
            dock = {
              animation = "none";
              clip-shadow-above = true;
            };
            desktop = {
              animation = "none";
              shadow = false;
            };
            dnd = { shadow = true; };
            popup_menu = { shadow = false; };
            utility = { shadow = false; };
          };

          shadow = cfg.shadows.enable;
          fading = cfg.animations.enable;
          animations = cfg.animations.enable;
        }
        (mkIf cfg.shadows.enable {
          shadow-radius = 11;
          shadow-opacity = 0.85;
          shadow-offset-x = -7;
          shadow-offset-y = -7;
          shadow-exlude = [
            "class_i = 'Firefox' && window_type = 'utility'"
            "class_i = 'Firefox' && window_type = 'popup_menu'"
            "class_g ~= 'xdg-desktop-portal' && _NET_FRAME_EXTENTS@:c && window_type = 'dialog'"
            "class_g ~= 'xdg-desktop-portal' && window_type = 'menu'"
            "_NET_FRAME_EXTENTS@:c && WM_WINDOW_ROLE@:s = 'Popup'"
          ];
        })
        (mkIf cfg.animations.enable {
          fade-in-step = 0.12;
          fade-out-step = 0.12;

          #animation-for-transient-window = "zoom";
          animation-for-open-window = "zoom";
          animation-for-unmap-window = "zoom";
          #animation-for-workspace-switch-in = "slide-right";
          #animation-for-workspace-switch-out = "slide-left";
          animation-stiffness = 400;
          animation-dampening = 20;
          animation-window-mass = 0.5;
          animation-delta = 8;
          animation-clamping = true;
        })
      ];
    };
  };
}
