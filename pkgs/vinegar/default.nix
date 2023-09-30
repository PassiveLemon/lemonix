# Taken from #251795 and slightly modified. Will remove this from my repo once it gets merged.

{ lib,
  fetchFromGitHub,
  buildGoModule,
  wine,
  symlinkJoin,
  makeWrapper
}:
let
  unwrapped = buildGoModule rec {
    pname = "vinegar";
    version = "1.4.2";

    src = fetchFromGitHub {
      owner = "vinegarhq";
      repo = "vinegar";
      rev = "v${version}";
      hash = "sha256-K/jxCBOcmGb5uU8F/XV5Gz0R8ZsBqKzLde3d2tKbnwA=";
    };

    vendorHash = null;

    ldflags = [ "-s" "-w" ];

    meta = with lib; {
      description = "An open-source, minimal, configurable, fast bootstrapper for running Roblox on Linux";
      homepage = "https://github.com/vinegarhq/vinegar";
      changelog = "https://github.com/vinegarhq/vinegar/releases/tag/v${version}";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ passivelemon ];
      platforms = [ "x86_64-linux" ];
    };
  };
in
symlinkJoin {
  name = "vinegar";
  paths = [ unwrapped ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/vinegar \
      --prefix PATH : ${lib.makeBinPath [ wine ]}
  '';
}
