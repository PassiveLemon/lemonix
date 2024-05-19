{ inputs, pkgs, config, lib, ... }: {
  imports = [
    inputs.lemonake.nixosModules.alvr
    ./wivrn.nix
  ];

  environment.systemPackages = with pkgs; [
    sidequest autoadb
    xrgears
    BeatSaberModManager
  ];

  services = {
    udev.packages = with pkgs; [
      android-udev-rules
    ];
    wivrn = {
      enable = true;
      package = pkgs.unstable.callPackage ../../pkgs/wivrn { };
      openFirewall = true;
      highPriority = true;
      defaultRuntime = true;
    };
  };

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    adb.enable = true;
    alvr = { # Module of lemonake
      enable = true;
      package = inputs.lemonake.packages.${pkgs.system}.alvr;
      openFirewall = true;
    };
  };

  hardware = {
    opengl.extraPackages = with pkgs; [
      inputs.lemonake.packages.${pkgs.system}.monado-vulkan-layers
    ];
  };
}
