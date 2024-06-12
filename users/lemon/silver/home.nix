{ inputs, pkgs, config, lib, ... }: {
  imports = [
    ../common/home.nix
    ./modules/customization.nix
  ];

  home = {
    packages = with pkgs; [
      headsetcontrol
      guitarix
      easytag #onthespot
      xclicker

      (callPackage ../../../pkgs/onthespot { })

      inputs.lemonake.packages.${pkgs.system}.animdl
      inputs.lemonake.packages.${pkgs.system}.hd2pystratmacro
      inputs.lemonake.packages.${pkgs.system}.poepyautopot
      inputs.lemonake.packages.${pkgs.system}.tilp2

      zed-editor

      # Development
      jq dotnet-sdk_8
      act
      nvfetcher nixpkgs-review
      trivy snyk grype
    ];
    file = {
      ".config/autostart/" = {
        source = ./home/.config/autostart;
        recursive = true;
      };
      ".config/awesome/config" = {
        source = ./home/.config/awesome/config;
        recursive = true;
      };
      ".config/awesome/signal" = {
        source = ./home/.config/awesome/signal;
        recursive = true;
      };
      ".config/awesome/ui" = {
        source = ./home/.config/awesome/ui;
        recursive = true;
      };
      ".config/awesome/liblua_pam.so" = {
        source = ./home/.config/awesome/liblua_pam.so;
        recursive = true;
      };
      ".local/bin/passivelemon" = {
        source = ./home/.local/bin/passivelemon;
        recursive = true;
      };
    };
    stateVersion = "23.05";
  };

  services = {
    autorandr.enable = true;
    megasync.enable = true;
  };

  programs = {
    autorandr = {
      enable = true;
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
              position = "0x0";
              mode = "1920x1080";
              rate = "143.85";
              dpi = 96;
              gamma = "1.0:0.92:0.92";
            };
            "DP-2" = {
              enable = false; # Currently malfunctional so it's getting replaced.
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
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/discord-409416265891971072" = "discord-409416265891971072.desktop";
      };
    };
    desktopEntries = {
      "alvr-autoadb" = {
        name = "alvr-autoadb";
        exec = "/home/lemon/.local/bin/passivelemon/alvr-autoadb.sh";
        terminal = false;
      };
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
      "electron-24.8.6" # Feishin
      "electron-25.9.0"
      "freeimage-unstable-2021-11-01"
    ];
  };
}

