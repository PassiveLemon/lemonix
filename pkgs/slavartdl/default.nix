{ buildGoModule,
  fetchFromGitHub,
  lib
}:
buildGoModule rec {
  pname = "corrupter";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "tywil04";
    repo = "slavartdl";
    rev = "v${version}";
    sha256 = "sha256-lY57HTW28EHwcTOmNNeC+h1cDUOigCTXMU9q1ESuJmw=";
  };

  vendorHash = "sha256-JBrCPMob8K5hKs44A6u1ensGg3sypQDiCPaw1PJy0yo=";

  meta = with lib; {
    description = "Simple tool written in Go to download music using the SlavArt Divolt server";
    homepage = "https://github.com/tywil04/slavartdl";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
  };
}
