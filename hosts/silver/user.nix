{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/user.nix
    ../../modules/nixos/bluetooth.nix
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.nix-gaming.nixosModules.steamCompat
    ../../modules/nixos/steamvr.nix
  ];

  # Configs
  services = {
    pipewire = {
      lowLatency = { # Module of nix-gaming
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
    steam = {
      enable = true;
      extraCompatPackages = with inputs.nix-gaming.packages.${pkgs.system}; [ # Module of nix-gaming
        proton-ge northstar-proton faf-client-bin
      ];
    };
  };
}
