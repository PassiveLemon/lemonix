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
      hardwarePackage = pkgs.unstable.xr-hardware;
      openFirewall = true;
      highPriority = true;
      defaultRuntime = true;
    };
  };

  programs = {
    steam = {
      enable = true;
      # Until the change gets ported to stable
      #extraCompatPackages = with inputs.nix-gaming.packages.${pkgs.system}; [
      #  proton-ge northstar-proton faf-client-bin
      #];
    };
    adb.enable = true;
    alvr = { # Module of lemonake
      enable = true;
      package = inputs.lemonake.packages.${pkgs.system}.alvr;
      openFirewall = true;
    };
  };

  hardware.opengl.extraPackages = with pkgs; [ 
    (callPackage ../../pkgs/monado-vulkan-layers { })
  ];
}
