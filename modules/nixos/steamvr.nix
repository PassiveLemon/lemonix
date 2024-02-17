{ inputs, pkgs, config, lib, ... }: {
  imports = [
    inputs.lemonake.nixosModules.alvr
  ];

  environment.systemPackages = with pkgs; [
    BeatSaberModManager autoadb
  ];
  services.udev.packages = [
    pkgs.android-udev-rules
  ];
  programs = {
    adb.enable = true;
    alvr = { # Module of lemonake
      enable = true;
      package = inputs.lemonake.packages.${pkgs.system}.alvr;
      openFirewall = true;
    };
  };
}
