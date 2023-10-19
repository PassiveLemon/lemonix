{ inputs, outputs, pkgs, config, lib, ... }: {
  home.packages = with pkgs; [
    # Theme/Icon
    lxappearance matcha-gtk-theme papirus-icon-theme
    volantes-cursors
    # Font
    fira (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
    material-design-icons
  ];

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    gtk3 = {
      extraConfig = {
        gtk-cursor-theme-name = "volantes_cursors";
        gtk-theme-name = "Matcha-dark-aliz";
        gtk-icon-theme-name = "Papirus";
        gtk-font-name = "Fira Sans Medium 10";
        gtk-cursor-theme-size = 0;
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
      };
      bookmarks = [
        "file:///home/lemon/.local/share/Trash"
        "file:///home/HDD2TBEXT4"
        "file:///home/BACKUPDRIVE"
        "file:///home/HDD2TBEXT4/Downloads"
        "file:///home/lemon/Documents/GitHub"
        "file:///home/lemon/.steam/steam/steamapps/common"
      ];
    };
  };
}
