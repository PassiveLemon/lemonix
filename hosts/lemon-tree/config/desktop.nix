{ config, pkgs, ... }: {
  xdg.desktopEntries = {
    gdlauncher = {
      name = "GDLauncher";
      exec = "appimage-run /home/lemon/Standalone/GDLauncher-linux-setup.AppImage --no-sandbox";
      terminal = false;
    };
    xclicker = {
      name = "xclicker";
      exec = "appimage-run /home/lemon/Standalone/xclicker_amd64.AppImage";
      terminal = false;
    };
    r2modman = {
      name = "r2modman";
      exec = "appimage-run /home/lemon/Standalone/r2modman.AppImage --no-sandbox";
      terminal = false;
    };
    sd-comfyui = {
      name = "sd-comfyui";
      exec = "/home/lemon/Documents/GitHub/private/Scripts/ComfyUI.sh";
      terminal = true;
    };
    sd-auto = {
      name = "sd-auto";
      exec = "/home/lemon/Documents/GitHub/private/Scripts/Auto.sh";
      terminal = true;
    };
  };
}
