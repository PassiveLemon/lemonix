{ inputs, outputs, pkgs, config, lib, ... }: {
  gtk = {
    gtk3 = {
      bookmarks = [
        "file:///home/lemon/Downloads"
      ];
    };
  };
}
