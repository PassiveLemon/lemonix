{ lib
, appimageTools
, fetchurl
}:
let
  pname = "overte";
  version = "2025.05.1";

  src = fetchurl {
    url = "https://public.overte.org/build/overte/release/${version}/Overte-${version}-x86_64.AppImage";
    sha256 = "sha256-hWVIgduH/WyPZ53QDsbii0Ad8o4TB8lE0WjMcha7hVw=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/org.overte.interface.desktop -t $out/share/applications
    cp -r ${appimageContents}/usr/share/icons $out/share

    substituteInPlace $out/share/applications/org.overte.interface.desktop \
      --replace-fail 'Exec=/AppRun' 'Exec=overte'
  '';

  meta = with lib; {
    description = "an open source virtual worlds and social VR software which enables you to create and share virtual worlds as virtual reality (VR) and desktop experiences";
    homepage = "https://overte.org";
    changelog = "https://github.com/overte-org/overte/blob/master/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
    mainProgram = "overte";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}

