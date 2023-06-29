{ fetchFromGitHub, stdenv, pkgs, lib, ... }:
stdenv.mkDerivation rec {
  pname = "xclicker";
  version = "1.4.0";
  src = fetchFromGitHub {
    owner = "robiot";
    repo = "xclicker";
    rev = "v${version}";
    hash = "sha256-f47V81fQcfR04PTkaj/yByH7CLXuu8CnMnjwpKZO2qE=";
  };

  nativeBuildInputs = with pkgs; [ gnumake meson ninja pkg-config gtk3 xorg.libXtst ];  

  buildPhase = ''
    make install
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./build/release/src/xclicker $out/bin
  '';

  meta = with lib; {
    description = "An open-source, easy to use, feature-rich, blazing fast Autoclicker for linux desktops using x11.";
    homepage = "https://xclicker.xyz/";
    changelog = "https://github.com/robiot/XClicker/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ PassiveLemon ];
    platforms = [ "x86_64-linux" ];
  };
}
