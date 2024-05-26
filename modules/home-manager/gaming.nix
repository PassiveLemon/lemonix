{ inputs, pkgs, config, lib, ... }:
let
  wivrn = pkgs.callPackage ../../pkgs/wivrn { };
  opencomp = pkgs.callPackage ../../pkgs/opencomposite { };
in
{
  imports = [
    inputs.lemonake.homeManagerModules.steamvr
  ];

  home = {
    packages = with pkgs; [
      protonup-ng
      gamemode dxvk
      r2modman
      lunar-client prismlauncher
      inputs.lemonake.packages.${pkgs.system}.gdlauncher-carbon-unstable
      bottles
      ludusavi

      # VR
      inputs.envision.packages.${pkgs.system}.envision
      wlx-overlay-s
      sidequest autoadb
      xrgears
      BeatSaberModManager
      opencomposite-helper
    ];
  };

  services = {
    steamvr = {
      runtimeOverride = {
        enable = true;
        # The Nix package for OpenComposite just doesn't work so I'm using Envision's build
        #path = "${opencomp}/lib/opencomposite";
        path = "/home/lemon/.local/share/envision/eb7732c3-e27c-4a93-bbd3-6fcd2f68f909/opencomposite/build";
      };
      activeRuntimeOverride = {
        enable = true;
        path = "${wivrn}/share/openxr/1/openxr_wivrn.json";
      };
    };
  };

  xdg = {
    mimeApps = {
      defaultApplications = {
        "x-scheme-handler/beatsaver" = "BeatSaberModManager-url-beatsaver.desktop";
        "x-scheme-handler/bsplaylist" = "BeatSaberModManager-url-bsplaylist.desktop";
        "x-scheme-handler/gdlauncher" = "gdlauncher.desktop";
        "x-scheme-handler/modelsaber" = "BeatSaberModManager-url-modelsaber.desktop";
        "x-scheme-handler/ror2mm" = "r2modman.desktop";
      };
    };
  };
}
