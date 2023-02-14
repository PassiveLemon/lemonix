{ config, pkgs, ... }: {
  xsession.windowManager.bspwm = {
    enable = true;
    extraConfigEarly = ''
      xrandr --output ######## --primary --mode 1920x1080 --rate 60.00 --rotate normal

      bspc monitor ####### -d I II III IV V

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
      polybar lemon-right &

      feh --bg-fill $HOME/.background-image &

      xsetroot -cursor_name left_ptr &
    '';
  };
}