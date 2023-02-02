{ config, pkgs, ... }: {
  xsession.windowManager.bspwm = {
    enable = true;
    extraConfigEarly = ''
      xrandr --output DP-2 --primary --mode 1920x1080 --rate 143.9 --rotate normal --output DP-0 --mode 1920x1080 --rate 143.9 --rotate normal --left-of DP-2

      bspc monitor DP-0 -d I II III IV V
      bspc monitor DP-2 -d VI VII VIII IX X

      bspc config pointer_motion_interval 40
      bspc config border_width 0
      bspc config window_gap 12
      bspc config split_ratio 0.50

      bspc config borderless_monocle true
      bspc config gapless_monocle true
    '';
    extraConfig = ''
      #killall eww
      #eww daemon &
      #eww open lemon &

      killall polybar
      polybar lemon-left &
      polybar lemon-right &

      feh --bg-fill /home/lemon/.background-image &

      xsetroot -cursor_name left_ptr &

      xinput set-prop "Glorious Model O" "Device Accel Constant Deceleration" 1.6
    '';
  };
}