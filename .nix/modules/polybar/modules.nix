{ config, pkgs, ... }: {
  services.polybar.config = {
    "module/bar" = {
      type = "custom/text";
      content = "%{T3}⏽%{T-}";
    };
    "module/bspwm" = {
      type = "internal/bspwm";
      pin-workspaces = true;
      label-font = 0;
      label-empty = "%{T2}%{T-}";
      label-empty-padding = 1;
      label-focused = "%{T2}%{T-}";
      label-focused-padding = 1;
      label-occupied = "%{T2}%{T-}";
      label-occupied-padding = 1;
      label-urgent = "%{T2}%{T-}";
      label-urgent-padding = 1;
    };
    "module/cpu" = {
      type = "internal/cpu";
      interval = 1;
      format = "<label>";
      format-prefix = "%{T3}%{T-}";
      format-prefix-foreground = "\${colors.dRed}";
      label = " %percentage%%";
      label-font = 0;
      label-foreground = "\${colors.dWhi}";
    };
    "module/date" = {
      type = "internal/date";
      interval = 360;
      date = "%a %h %e";
      format = "<label>";
      format-prefix = "%{T3}%{T-}";
      format-prefix-foreground = "\${colors.dMag}";
      label = " %date%";
      label-font = 0;
      label-foreground = "\${colors.dWhi}";
    };
    "module/eth" = {
      type = "internal/network";
      interval = 5;
      interface = "enp6s0";
      format-connected = "<label-connected>";
      format-connected-prefix = "%{T2}%{T-}";
      format-connected-foreground = "\${colors.lWhi}";
      format-disconnect = "<label-disconnected>";
      format-disconnected-prefix = "%{T2}%{T-}";
      format-disconnected-foreground = "\${colors.lWhi}";
      label-connected = " %essid%";
      label-connected-font = 0;
      label-connected-foreground = "\${colors.dWhi}";
      label-disconnected = " %essid% Offline";
      label-disconnected-font = 0;
      label-disconnected-foreground = "\${colors.dWhi}";
    };
    "module/memory" = {
      type = "internal/memory";
      interval = 1;
      format = "<label>";
      format-prefix = "%{T2}%{T-}";
      format-prefix-foreground = "\${colors.dGre}";
      label = " %percentage_used%%";
      label-font = 0;
      label-foreground = "\${colors.dWhi}";
    };
    "module/nix" = {
      type = "custom/text";
      content = "%{T3}%{T-}";
      content-foreground = "\${colors.lBlu}";
    };
    "module/powermenu" = {
      type = "custom/text";
      content = "%{T2}%{T-}";
      click-left = "sh $HOME/.config/rofi/powermenu.sh";
    };
    "module/sep" = {
      type = "custom/text";
      content = " ";
    };
    "module/time" = {
      type = "internal/date";
      interval = 5;
      time = "%I:%M %p";
      format = "<label>";
      format-prefix = "%{T3}%{T-}";
      format-prefix-foreground = "\${colors.dYel}";
      label = " %time%";
      label-font = 0;
      label-foreground = "\${colors.dWhi}";
    };
    "module/title" = {
      type = "internal/xwindow";
      format = "<label>";
      label = "%title%";
      label-font = 0;
      label-maxlen = 50;
      label-empty = "Desktop";
    };
    "module/volume" = {
      type = "internal/alsa";
      interval = 2;
      format-volume = "<label-volume>";
      format-volume-prefix = "%{T3}%{T-}";
      format-volume-foreground = "\${colors.dCya}";
      format-muted = "<label-muted>";
      format-muted-prefix = "%{T3}%{T-}";
      format-muted-foreground = "\${colors.dCya}";
      label-volume = " %percentage%%";
      label-volume-font = 0;
      label-volume-foreground = "\${colors.dWhi}";
      label-muted = " X%";
      label-muted-font = 0;
      label-muted-foreground = "\${colors.dWhi}";
    };
    "module/wlan" = {
      type = "internal/network";
      interval = 5;
      interface = "wlp5s0";
      format-connected = "<label-connected>";
      format-connected-prefix = "%{T2}%{T-}";
      format-connected-foreground = "\${colors.lWhi}";
      format-disconnect = "<label-disconnected>";
      format-disconnected-prefix = "%{T2}%{T-}";
      format-disconnected-foreground = "\${colors.lWhi}";
      label-connected = " %essid%";
      label-connected-font = 0;
      label-connected-foreground = "\${colors.dWhi}";
      label-disconnected = " %essid% Offline";
      label-disconnected-font = 0;
      label-disconnected-foreground = "\${colors.dWhi}";
    };
  };
}