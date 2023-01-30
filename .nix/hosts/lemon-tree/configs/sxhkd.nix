{ config, pkgs, ... }: {
  services.sxhkd.keybindings = {
    # Custom
    "super + Return" = "kitty";
    "super + @space" = "rofi -show drun -theme $HOME/.config/rofi/lemon.rasi";
    "super + p" = "sh /home/lemon/.config/rofi/powermenu.sh";
    "Print" = "flameshot gui";
    # Bspwm
    "super + alt + r" = "bspc wm -r";
    "super + alt + t" = "pkill -USR1 -x sxhkd";
    "super + {_,shift + }Escape" = "bspc node -{c,k}";
    "super + g" = "bspc node -s biggest.window";
    # State/flags
    "super + {t,shift + t,f,m}" = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen}";
    "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '^{1-9,10}'";
    # Move/resize
    "super + alt + {h,j,u,k}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
    "super + alt + shift + {h,j,u,k}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";
    "super + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";
  };
}