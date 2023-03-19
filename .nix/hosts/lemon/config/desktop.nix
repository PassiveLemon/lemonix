{ config, pkgs, ... }: {
  xdg.desktopEntries = {
    gdlauncher = {
      name = "GDLauncher";
      exec = "appimage-run /home/lemon/Standalone/GDLauncher-linux-setup.AppImage --no-sandbox";
      terminal = false;
    };
    r2modman = {
      name = "r2modman";
      exec = "appimage-run /home/lemon/Standalone/r2modman.AppImage --no-sandbox";
      terminal = false;
    };
    stablediff = {
      name = "stable-diff";
      exec = "/home/lemon/Standalone/test/stable-diffusion-webui-docker/STABDIF.sh";
      terminal = true;
    };
  };
}