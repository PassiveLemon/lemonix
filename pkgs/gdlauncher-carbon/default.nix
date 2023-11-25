{ lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  rustPlatform,
  nodejs-18_x,
  nodePackages,
  rustc,
  cargo,
  rustfmt,
  pkg-config,
  gcc,
  openssl
}:
stdenvNoCC.mkDerivation rec {
  pname = "gdlauncher-carbon";
  version = "0";

  src = fetchFromGitHub {
    owner = "gorilla-devs";
    repo = "gdlauncher-carbon";
    rev = "ace170f0ecf5e66068712f3ccdd8b78c49cbeb93";
    hash = "sha256-iXnXU2/xmMD4XLAlRcfNvPCjYdMRTCCg/UjYg3U145o=";
  };

  pnpm-deps = stdenvNoCC.mkDerivation {
    pname = "${pname}-pnpm-deps";
    inherit src version;

    nativeBuildInputs = [
      nodePackages.pnpm
    ];

    installPhase = ''
      export HOME=$(mktemp -d)
      pnpm config set store-dir $out
      pnpm install --ignore-scripts

      # Remove timestamp and sort the json files
      rm -rf $out/v3/tmp
      for f in $(find $out -name "*.json"); do
        sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
        jq --sort-keys . $f | sponge $f
      done
    '';

    dontFixup = true;
    outputHashMode = "recursive";
    #outputHash = "";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "builtin-psl-connectors-0.1.0" = "sha256-cmq14wlCCEVw29bj26XrogdiLlgk9QuOKyji4H4D16g=";
      "daedalus-0.1.20" = "sha256-b7GY6AnRj6lj8QN5rxDqKdmWONzHurSRPdvUfO2/Cos=";
      "graphql-parser-0.3.0" = "sha256-0ZAsj2mW6fCLhwTETucjbu4rPNzfbNiHu2wVTBlTNe4=";
      "httpz-0.0.3" = "sha256-S9CGrJflLunas+9AmyKVTLITPn2IAuBJWjDAgaym378=";
      "mobc-0.7.3" = "sha256-Ts2VVAuZakS+Sy/rEUrCe7RJX5MWs/TTO60c7mH+5sU=";
      "murmurhash32-0.2.0" = "sha256-JNt5/TG0Ez2DJr7LfyP9l76cMEV4p0RQXPVl3+GKQqw=";
      "prisma-client-rust-0.6.7" = "sha256-3HdjdvesPxOGJKZY5KyORXHshQpGVHIrv4hToCkTlSE=";
      "quaint-0.2.0-alpha.13" = "sha256-ux3ZAtbn3txB+zXx1ZwaO/8AHTBYnhohIDILVov3UXU=";
      "rspc-0.1.2" = "sha256-FNGD3onhN7TViscbTdm+hkF7sqbXaZoenCQMbr7yYo4=";
    };
  };

  nativeBuildInputs = [
    nodejs-18_x
    nodePackages.pnpm
    rustc
    cargo
    rustfmt
    pkg-config
    gcc
  ];
  buildInputs = [
    openssl
    openssl.dev
  ];

  preBuild = ''
    export HOME=$(mktemp -d)
    pnpm config set store-dir ${pnpm-deps}
    pnpm install --ignore-scripts --offline
    chmod -R +w node_modules
    pnpm rebuild
    pnpm build
  '';

  meta = with lib; {
    description = "A simple, yet powerful Minecraft custom launcher with a strong focus on the user experience";
    homepage = "https://gdlauncher.com/";
    #changelog = "https://github.com/gorilla-devs/GDLauncher-Carbon/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
  };
}
