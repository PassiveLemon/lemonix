{ config, ... }: {
  imports = [
    ../common/user.nix
  ];

  # Obs virtual camera
  boot = {
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
  };

  services = {
    flatpak.enable = true;
    pipewire = {
      extraConfig = {
        pipewire."92-reduce-popping" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 512;
            "default.clock.min-quantum" = 256;
            "default.clock.max-quantum" = 1024;
          };
        };
      };
    };
  };
}

