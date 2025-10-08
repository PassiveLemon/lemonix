{ pkgs, ... }: {
  imports = [
    ../common/home.nix
    ./modules/customization.nix
  ];

  home = {
    packages = with pkgs; [
      brightnessctl
      fusuma
    ];
    file = {
      ".bash_profile" = {
        source = ./home/.bash_profile;
      };
    };
    pointerCursor.size = 32;
    stateVersion = "25.05"; # Don't change unless you know what you are doing
  };

  programs = {
    autorandr.profiles = {
      "Default" = {
        fingerprint.eDP-1 = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
        config = {
          "eDP-1" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "2256x1504";
            rate = "60.00";
            # 85% scale in X and Y. Using the autorandr scale option doesn't always work
            transform = [
              [ 0.85 0.0 0.0 ]
              [ 0.0 0.85 0.0 ]
              [ 0.0 0.0 1.0 ]
            ];
            dpi = 120;
            gamma = "1.0:0.92:0.92";
          };
        };
      };
      "External" = {
        fingerprint.eDP-1 = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
        fingerprint.DP-2 = "00ffffffffffff0006b3af24a41a030004200104a5351e783b51b5a4544fa0260d5054bfcf00814081809500714f81c0b30001010101023a801871382d40582c45000f282100001e0882805070384d400820f80c0f282100001a000000fd003090b4b422010a202020202020000000fc00415355532056503234390a20200134020330f14d010304131f120211900e0f1d1e230907078301000067030c00100000446d1a000002013090000000000000fe5b80a070383540302035000f282100001a866f80a070384040302035000f282100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000b3";
        config = {
          "eDP-1" = {
            enable = true;
            primary = true;
            mode = "2256x1504";
            position = "0x0";
            rate = "60.00";
            dpi = 120;
            gamma = "1.0:0.92:0.92";
          };
          "DP-2" = {
            enable = true;
            primary = false;
            mode = "1920x1080";
            position = "2256x0";
            dpi = 96;
          };
        };
      };
    };
  };

  xdg = {
    configFile = {
      "awesome/config/user.lua" = {
        source = ./home/.config/awesome/config/user.lua;
      };
      "awesome/ui/init.lua" = {
        source = ./home/.config/awesome/ui/init.lua;
      };
      "lite-xl/user.lua" = {
        source = ./home/.config/lite-xl/user.lua;
      };
    };
  };

  nixpkgs = {
    config.permittedInsecurePackages = [
    ];
  };
}

