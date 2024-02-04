{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    inputs.lemonake.nixosModules.alvr
  ];

  environment.systemPackages = with pkgs; [
    BeatSaberModManager
  ];
  programs = {
    alvr = { # Module of lemonake
      enable = true;
      package = inputs.lemonake.packages.${pkgs.system}.alvr;
      openFirewall = true;
    };
  };
}
