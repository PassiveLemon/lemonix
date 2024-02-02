{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; },
  lib ? pkgs.lib,
  buildDotnetModule ? pkgs.buildDotnetModule,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  dotnet-sdk ? pkgs.dotnet-sdk,
  icu70 ? pkgs.icu70,
  pipewire ? pkgs.pipewire,
  xorg ? pkgs.xorg,
}:

buildDotnetModule rec {
  pname = "wlxoverlay";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "galister";
    repo = "wlxoverlay";
    rev = "v${version}";
    hash = "sha256-dJa5PRPP5WLGcl4TxfYCeChzT1DREO4eUB96TJDGg3Y=";
  };

  projectFile = "WlxOverlay.csproj";

  nugetDeps = ./deps.nix;

  nativeBuildInputs = [
    dotnet-sdk
    icu70
    pipewire
    xorg.libxcb
    xorg.libxshmfence
    xorg.libXinerama
    xorg.libXrandr
  ];

  buildInputs = [
    dotnet-sdk
    icu70
    pipewire
    xorg.libxcb
    xorg.libxshmfence
    xorg.libXinerama
    xorg.libXrandr
  ];

  meta = with lib; {
    description = "A simple OpenVR overlay for Wayland and X11 desktops";
    homepage = "https://github.com/galister/WlxOverlay";
    changelog = "https://github.com/galister/WlxOverlay/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "WlxOverlay";
  };
}
