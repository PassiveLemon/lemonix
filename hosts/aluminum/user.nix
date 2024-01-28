{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/user.nix
  ];

  # Configs
  services = {
    xserver = {
      libinput = {
        touchpad = {
          buttonMapping = "1 1 3 4 5 6 7";
          middleEmulation = false;
          accelProfile = "flat";
          naturalScrolling = true;
        };
      };
    };
    logind.extraConfig = ''
      HandlePowerKey=suspend
      HandleLidSwitch=suspend-then-hibernate
      IdleAction=ignore
      IdleActionSec=60m
    '';
  };
  blueman.enable = true;
}
