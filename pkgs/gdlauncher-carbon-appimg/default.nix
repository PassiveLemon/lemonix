{ lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "gdlauncher-carbon";
  version = "alpha.1703732789";
  src = fetchurl {
    url = "https://cdn-raw.gdl.gg/launcher/GDLauncher__2.0.0-${version}__linux__x64.AppImage";
    hash = "sha256-xWdqgKnVwf90Zzxa2k55VhWE2KiJNBDwsfZtEVsHEtA=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mv $out/bin/${pname}-${version} $out/bin/${pname}

    install -Dm444 ${appimageContents}/@gddesktop.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/@gddesktop.png $out/share/pixmaps/gdlauncher-carbon.png
    substituteInPlace $out/share/applications/@gddesktop.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname}' \
      --replace 'Icon=@gddesktop' 'Icon=gdlauncher-carbon'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "A simple, yet powerful Minecraft custom launcher with a strong focus on the user experience";
    homepage = "https://gdlauncher.com/";
    license = licenses.bsl11;
    mainProgram = "gdlauncher-carbon";
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
  };
}
