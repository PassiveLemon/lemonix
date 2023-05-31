{ finputs, outputs, fetchurl, appimageTools, ... }:
let
  pname = "gdlauncher";
  version = "1.1.30";
  src = fetchurl {
    url = "https://github.com/gorilla-devs/GDLauncher/releases/download/v${version}/GDLauncher-linux-setup.AppImage";
    sha256 = "sha256-hKyJ5v++0PGC/nWEZdOscpk5hY5ooJNUuMPmLKCgJ68=";
  };
  name = "${pname}-${version}";
  appimageContents = appimageTools.extractType2 { inherit name src; };
in
appimageTools.wrapType2 rec {
  inherit name src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/${name}.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/${name}.png -t $out/share/pixmaps
    substituteInPlace $out/share/applications/${name}.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${name} %U'
  '';
}
