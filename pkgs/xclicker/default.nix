{ pkgs, lib, ... }:
let
  pname = "xclicker";
  version = "1.4.0";
  name = "${pname}-${version}";
  src = pkgs.fetchurl {
    url = "https://github.com/robiot/xclicker/releases/download/v${version}/xclicker_${version}_amd64.AppImage";
    hash = "sha256-aaFUC7NcMbChkYi+fGkGcFIipxJFzrQ4qm1KBLJrBFM=";
  };

  appimageContents = pkgs.appimageTools.extractType2 { inherit name src; };
in
pkgs.appimageTools.wrapType2 rec {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -Dm444 ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
  '';

  meta = with lib; {
    description = "XClicker is an open-source, easy to use, feature-rich, blazing fast Autoclicker for linux desktops using x11.";
    homepage = "https://github.com/robiot/XClicker";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ "PassiveLemon" ];
    platforms = [ "x86_64-linux" ];
  };
}
