{ inputs, pkgs, config, lib, ... }: {
  home = {
    packages = with pkgs; [
      protonup-ng
      gamemode dxvk
      r2modman
      lunar-client prismlauncher
      inputs.lemonake.packages.${pkgs.system}.gdlauncher-carbon-unstable
      bottles
      ludusavi
    ];
  };

  xdg = {
    mimeApps = {
      defaultApplications = {
        "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
        "x-scheme-handler/ror2mm" = "r2modman.desktop";
      };
    };
  };
}
