{ appimageTools, fetchurl, ... }:
appimageTools.wrapType2 rec {
  pname = "gdlauncher";
  version = "1.1.30";
  src = fetchurl {
    url = "https://github.com/gorilla-devs/GDLauncher/releases/download/v${version}/GDLauncher-linux-setup.AppImage";
    hash = "sha256-4cXT3exhoMAK6gW3Cpx1L7cm9Xm0FK912gGcRyLYPwM=";
  };
  name = "${pname}-${version}";

  extraInstallCommands = ''
    install -Dm444 ${pname}.desktop -t $out/share/applications
    install -Dm444 ${pname}.png -t $out/share/pixmaps
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
  '';
}
