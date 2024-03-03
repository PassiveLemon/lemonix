{ inputs, pkgs, config, lib, ... }: {
  imports = [
    inputs.lemonake.nixosModules.alvr
    ./monado.nix
    ./wivrn.nix
  ];

  environment.systemPackages = with pkgs; [
    sidequest autoadb BeatSaberModManager
    unstable.opencomposite
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
    monado = { # Local import until it gets ported to 23.11 stable
      enable = false;
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
