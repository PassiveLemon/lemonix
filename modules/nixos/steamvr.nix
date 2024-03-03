{ inputs, pkgs, config, lib, ... }: {
  imports = [
    inputs.lemonake.nixosModules.alvr
    ./monado.nix
  ];

  environment.systemPackages = with pkgs; [
    monado autoadb BeatSaberModManager
  ];
  services = {
    udev.packages = [
      pkgs.android-udev-rules
    ];
    monado = { # Local import until it gets ported to 23.11 stable
      enable = true;
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
