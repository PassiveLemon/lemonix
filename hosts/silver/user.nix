{ inputs, outputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/user.nix
    inputs.lemonake.nixosModules.alvr
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];

  # Configs
  services = {
    pipewire = {
      lowLatency = { # Module of Nix-gaming
        enable = true;
        quantum = 128;
        rate = 48000;
      };
    };
    udev.extraRules = ''
      ACTION!="add|change", GOTO="headset_end"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1b1c", ATTRS{idProduct}=="0a51", TAG+="uaccess"
      LABEL="headset_end"
    ''; # Headsetcontrol udev rule
  };
  programs = {
    alvr = { # Module of lemonake
      enable = true;
      package = inputs.lemonake.packages.${pkgs.system}.alvr;
      openFirewall = true;
    };
  };
}
