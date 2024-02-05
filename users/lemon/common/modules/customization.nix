{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    lxappearance
    (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
  ];

  fonts.fontconfig.enable = true;

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };
  gtk = {
    enable = true;
    theme = {
      name = "Matcha-dark-aliz";
      package = pkgs.matcha-gtk-theme;
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "volantes_cursors";
      package = pkgs.volantes-cursors;
      size = 16;
    };
    font = {
      name = "Fira Sans Medium";
      package = pkgs.fira;
      size = 10;
    };
    gtk3 = {
      extraConfig = {
        gtk-toolbar-style = "GTK_TOOLBAR_BOTH";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
        gtk-button-images = 1;
        gtk-menu-images = 1;
        gtk-enable-event-sounds = 0;
        gtk-enable-input-feedback-sounds = 0;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
        gtk-modules = "gail:atk-bridge";
      };
      bookmarks = [
        "file:///home/lemon/.local/share/Trash"
        "file:///home/lemon/Documents"
      ];
    };
  };
  qt = {
    enable = true;
    platformTheme = "gtk3";
  };
  xdg.portal = {
    enable = true;
    config.common.default = [ "gtk" ];
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}
