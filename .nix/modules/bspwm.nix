{ config, pkgs, ... }: {
  xsession.windowManager.bspwm = {
    enable = true;
    extraConfigEarly = ''
      xrandr --output DP-0 --primary --mode 1920x1080 --rate 143.9 --rotate normal --output DP-2 --mode 1920x1080 --rate 143.9 --rotate normal --left-of DP-0

      # Basic config
      bspc monitor DP-2 -d 1 2 3 4 5
      bspc monitor DP-0 -d 6 7 8 9 10

      bspc config pointer_motion_interval 7
      bspc config border_width 0
      bspc config window_gap 12
      bspc config split_ratio 0.50
      bspc config borderless_monocle true
      bspc config gapless_monocle true
      #bspc config ignore_ewmh_focus true

      # Rules (Don't seem to work)
      bspc rule -a easyeffects desktop='^5' state=tiled follow=off focus=off -o
      bspc rule -a Pcmanfm state=floating follow=on focus=on
      bspc rule -a Lxappearance state=floating follow=on focus=on
    '';
    extraConfig = ''
      killall polybar eww easyeffects &

      # Startup
      feh --bg-fill $HOME/.background-image &
      pamixer --set-limit 100 &
      xsetroot -cursor_name left_ptr &
      xinput set-prop "Glorious Model O" "Device Accel Constant Deceleration" 1.6
      easyeffects &
      polybar lemon-left &
      polybar lemon-right &

      # Disabled until I actually set it up
      # eww daemon &
      # eww open lemon &
    '';
  };
}