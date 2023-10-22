{ lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "xclicker";
  version = "1.5.0";
  src = fetchurl {
    url = "https://github.com/robiot/xclicker/releases/download/v${version}/xclicker_${version}_amd64.AppImage";
    hash = "sha256-eTKL+pFqEg1FZKbH580Jw51mIiFaL7tpKTSuxYcVaGE=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mv $out/bin/${pname}-${version} $out/bin/${pname}

    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=${pname}'
  '';

  meta = with lib; {
    description = "An open-source, easy to use, feature-rich, blazing fast Autoclicker for linux desktops using x11.";
    homepage = "https://github.com/robiot/XClicker";
    changelog = "https://github.com/robiot/XClicker/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
  };
}
