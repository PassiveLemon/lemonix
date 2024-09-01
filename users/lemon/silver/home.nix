{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/home.nix
    ./modules/customization.nix
  ];

  home = {
    packages = with pkgs; [
      headsetcontrol
      guitarix
      easytag onthespot
      #mangal

      inputs.lemonake.packages.${pkgs.system}.animdl
      inputs.lemonake.packages.${pkgs.system}.hd2pystratmacro
      inputs.lemonake.packages.${pkgs.system}.poepyautopot
      inputs.lemonake.packages.${pkgs.system}.tilp2

      zed-editor

      # Development
      act dive trivy
      nixpkgs-review nixfmt-rfc-style
      nvfetcher
    ];
    file = {
      ".config/autostart/hardware.sh" = {
        source = ./home/.config/autostart/hardware.sh;
      };
      ".config/autostart/programs.sh" = {
        source = ./home/.config/autostart/programs.sh;
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
      ".config/awesome/ui/resource.lua" = {
        source = ./home/.config/awesome/ui/resource.lua;
      };
      ".config/awesome/ui/crosshair.lua" = {
        source = ./home/.config/awesome/ui/crosshair.lua;
      };
      ".config/awesome/liblua_pam.so" = {
        source = ./home/.config/awesome/liblua_pam.so;
      };
      ".config/lite-xl/init.lua" = {
        source = ./home/.config/lite-xl/init.lua;
      };
      ".local/bin/passivelemon" = {
        source = ./home/.local/bin/passivelemon;
        recursive = true;
      };
    };
    stateVersion = "23.05";
  };

  programs = {
    autorandr = {
      profiles = {
        "Default" = {
          fingerprint = {
            DP-2 = "00ffffffffffff0006b3af24a41a030004200104a5351e783b51b5a4544fa0260d5054bfcf00814081809500714f81c0b30001010101023a801871382d40582c45000f282100001e0882805070384d400820f80c0f282100001a000000fd003090b4b422010a202020202020000000fc00415355532056503234390a20200134020330f14d010304131f120211900e0f1d1e230907078301000067030c00100000446d1a000002013090000000000000fe5b80a070383540302035000f282100001a866f80a070384040302035000f282100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000b3";
            DP-0 = "00ffffffffffff0006b3af240afc03000e1e0104a5351e783b51b5a4544fa0260d5054bfcf00814081809500714f81c0b30001010101023a801871382d40582c45000f282100001e0882805070384d400820f80c0f282100001a000000fd003090b4b422010a202020202020000000fc00415355532056503234390a202001e4020322f14d010304131f120211900e0f1d1e230907078301000067030c0010000044fe5b80a070383540302035000f282100001a866f80a070384040302035000f282100001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b";
          };
          config = {
            "DP-0" = {
              enable = true;
              primary = true;
              position = "1920x0";
              mode = "1920x1080";
              rate = "143.85";
              dpi = 96;
              gamma = "1.0:0.92:0.92";
            };
            "DP-2" = {
              enable = true;
              primary = false;
              position = "0x0";
              mode = "1920x1080";
              rate = "143.85";
              dpi = 96;
              gamma = "1.0:0.92:0.92";
            };
          };
        };
      };
    };
  };

  xdg = {
    desktopEntries = {
      "sd-comfy" = {
        name = "sd-comfy";
        exec = "/home/lemon/.local/bin/passivelemon/sd-comfy.sh";
        terminal = true;
      };
      "sd-auto" = {
        name = "sd-auto";
        exec = "/home/lemon/.local/bin/passivelemon/sd-auto.sh";
        terminal = true;
      };
    };
  };

  nixpkgs = {
    config.permittedInsecurePackages = [
    ];
  };
}

