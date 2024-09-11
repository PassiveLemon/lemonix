{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/home.nix
    ./modules/customization.nix
  ];

  home = {
    packages = with pkgs; [
      brightnessctl
    ];
    file = {
      ".config/autostart/programs.sh" = {
        source = ./home/.config/autostart/programs.sh;
      };
      ".config/awesome/config/init.lua" = {
        source = ./home/.config/awesome/config/init.lua;
      };
      ".config/awesome/signal/init.lua" = {
        source = ./home/.config/awesome/signal/init.lua;
      };
      ".config/awesome/ui/init.lua" = {
        source = ./home/.config/awesome/ui/init.lua;
      };
      ".config/awesome/ui/bar.lua" = {
        source = ./home/.config/awesome/ui/bar.lua;
      };
      ".config/awesome/liblua_pam.so" = {
        source = ./home/.config/awesome/liblua_pam.so;
      };
      ".config/lite-xl/init.lua" = {
        source = ./home/.config/lite-xl/init.lua;
      };
      ".bash_profile" = {
        source = ./home/.bash_profile;
      };
    };
    pointerCursor.size = 32;
    stateVersion = "23.11";
  };

  programs = {
    autorandr = {
      profiles = {
        "Default" = {
          fingerprint = {
            eDP-1 = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
          };
          config = {
            "eDP-1" = {
              enable = true;
              primary = true;
              position = "0x0";
              mode = "2256x1504";
              rate = "60.00";
              dpi = 120;
              gamma = "1.0:0.92:0.92";
            };
          };
        };
      };
    };
  };

  nixpkgs = {
    config.permittedInsecurePackages = [
    ];
  };
}

