{ inputs, pkgs, config, lib, ... }: {
  imports = [
    inputs.lemonake.nixosModules.alvr
    ./wivrn.nix
  ];

  environment.systemPackages = with pkgs; [
    xrgears sidequest autoadb BeatSaberModManager
  ];
  services = {
    udev.packages = [
      pkgs.android-udev-rules
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
    adb.enable = true;
    alvr = { # Module of lemonake
      enable = true;
      package = inputs.lemonake.packages.${pkgs.system}.alvr;
      openFirewall = true;
    };
  };
}
