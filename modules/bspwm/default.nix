{ config, pkgs, ... }: {
  imports = [
    ./sxhkd.nix
    ../polybar/default.nix
    ../dunst.nix
  ];
  xsession.windowManager.bspwm = {
    enable = true;
    extraConfigEarly = ''
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
      xsetroot -cursor_name left_ptr &
      test -f $HOME/.config/autostart/bspwm.sh && bash $HOME/.config/autostart/bspwm.sh &
    '';
  };
}
