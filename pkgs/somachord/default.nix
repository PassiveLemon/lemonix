{ lib
, appimageTools
# , fetchurl
}:
let
  pname = "somachord";
  version = "8dd28f5a1b32bfe5832ff6646a313451cb137e16";
  # Get this from the workflow artifacts
  src = ./Somachord-1.0.0.AppImage;

  # Only action artifacts are available and we can't fetch those
  # src = fetchurl {
  #   url = "https://github.com/sammy-ette/Somachord/";
  #   hash = "";
  # };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/somachord.desktop -t $out/share/applications
    cp -r ${appimageContents}/usr/share/icons $out/share

    substituteInPlace $out/share/applications/somachord.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=somachord'
  '';

  meta = with lib; {
    description = "A simple self-hosted Subsonic web client";
    homepage = "https://github.com/sammy-ette/Somachord/";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
    mainProgram = "somachord";
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}

