{ fetchurl, appimageTools, lib, ...}:
let
  name = "gdlauncher";
  src = fetchurl {
    url = "https://github.com/gorilla-devs/GDLauncher/releases/download/v1.1.29/GDLauncher-linux-setup.AppImage";
    sha256 = "sha256-hKyJ5v++0PGC/nWEZdOscpk5hY5ooJNUuMPmLKCgJ68=";
  };
  appimageContents = appimageTools.extractType2 { inherit name src; };
in appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    
    # Installs .desktop files
    install -Dm444 ${appimageContents}/${name}.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/${name}.png -t $out/share/pixmaps
    substituteInPlace $out/share/applications/${name}.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${name}'
  '';
}