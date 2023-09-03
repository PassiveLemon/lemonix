{ config, pkgs, ... }: {
  imports = [
    ./sxhkd.nix
  ];
  xsession.windowManager.bspwm = {
    enable = true;
    extraConfigEarly = ''
      xrandr --output DP-0 --primary --mode 1920x1080 --rate 143.9 --rotate normal --output DP-2 --mode 1920x1080 --rate 143.9 --rotate normal --left-of DP-0
      xrandr --output DP-0 --gamma 1.0:0.92:0.92 --output DP-2 --gamma 1.0:0.92:0.92
      bspc monitor DP-2 -d 1 2 3
      bspc monitor DP-0 -d 4 5 6
      bspc config pointer_motion_interval 7
      bspc config focus_follows_pointer true
      bspc config border_width 2
      bspc config normal_border_color "#000000"
      bspc config focused_border_color "#535d6c"
      bspc config window_gap 12
      bspc config split_ratio 0.50
      bspc config borderless_monocle true
      bspc config gapless_monocle true
    '';
    extraConfig = ''
      pgrep -x sxhkd > /dev/null || sxhkd &
      feh --bg-fill $HOME/.wallpaper-image &
      pgrep -x polybar > /dev/null || polybar lemon-left &
      pgrep -x polybar > /dev/null || polybar lemon-right &
      xsetroot -cursor_name left_ptr &
      pgrep -x picom > /dev/null || picom --experimental-backend -b &
      pgrep -x easyeffects > /dev/null || easyeffects --gapplication-service &
      pgrep -x nm-applet > /dev/null || nm-applet &
      pgrep -x megasync > /dev/null || megasync &
    '';
  };
}
