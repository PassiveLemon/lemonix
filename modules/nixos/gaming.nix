{ inputs, pkgs, config, lib, ... }: {
  imports = [
    inputs.lemonake.nixosModules.alvr
    ./wivrn.nix
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
      monadoEnvironment = {
        XRT_COMPOSITOR_COMPUTE = "1";
        XRT_COMPOSITOR_LOG = "debug";
        XRT_LOG = "debug";
      };
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
