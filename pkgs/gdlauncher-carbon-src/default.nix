# WIP. CURRENTLY NOT FUNCTIONAL
{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; },
  lib ? pkgs.lib,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "gdlauncher-carbon";
  version = "0";

  src = pkgs.fetchFromGitHub {
    owner = "gorilla-devs";
    repo = "gdlauncher-carbon";
    rev = "b5392f0e70b391ab9805e34e68c64a98c6a502c3";
    hash = "sha256-hDIe1yfxpO96QkdyEP7kds8zkkxgg4SJYYkQLGb68Ac=";
  };

  pnpm-deps = pkgs.stdenvNoCC.mkDerivation {
    pname = "${pname}-pnpm-deps";
    inherit src version;

    nativeBuildInputs = with pkgs; [
      jq
      moreutils
      nodePackages.pnpm
      cacert
    ];

    installPhase = ''
      export HOME=$(mktemp -d)
      pnpm config set store-dir $out
      pnpm install --frozen-lockfile --ignore-script

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

  cargoDeps = pkgs.rustPlatform.importCargoLock {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "builtin-psl-connectors-0.1.0" = "sha256-cmq14wlCCEVw29bj26XrogdiLlgk9QuOKyji4H4D16g=";
      "daedalus-0.1.21" = "sha256-9lIEG74l9rZhdd8bb1kLvKutZo81ZB+YeWxWbMkzIio=";
      "graphql-parser-0.3.0" = "sha256-0ZAsj2mW6fCLhwTETucjbu4rPNzfbNiHu2wVTBlTNe4=";
      "httpz-0.0.3" = "sha256-S9CGrJflLunas+9AmyKVTLITPn2IAuBJWjDAgaym378=";
      "mobc-0.7.3" = "sha256-Ts2VVAuZakS+Sy/rEUrCe7RJX5MWs/TTO60c7mH+5sU=";
      "murmurhash32-0.2.0" = "sha256-GKzfGpbIui0Oby50W0W5XXfG+8O9BypNE+MUtnEMHZU=";
      "native-tls-0.2.11" = "sha256-aGh6RGwv0OG9977bOiYyEFm56AbtwkaZrhoq5/v/bK4=";
      "prisma-client-rust-0.6.7" = "sha256-3HdjdvesPxOGJKZY5KyORXHshQpGVHIrv4hToCkTlSE=";
      "quaint-0.2.0-alpha.13" = "sha256-ux3ZAtbn3txB+zXx1ZwaO/8AHTBYnhohIDILVov3UXU=";
      "rspc-0.1.2" = "sha256-FNGD3onhN7TViscbTdm+hkF7sqbXaZoenCQMbr7yYo4=";
    };
  };

  nativeBuildInputs = with pkgs; [
    rustPlatform.cargoSetupHook
    nodejs-18_x
    nodePackages.pnpm
    rustc
    cargo
    rustfmt
    pkg-config
    gcc
  ];
  buildInputs = with pkgs; [
    alsa-lib
    atk
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libappindicator-gtk3
    libdbusmenu
    libxkbcommon
    systemd
    nss
    nspr
    mesa
    pango
    zlib
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    openssl
    openssl.dev
  ];

  preBuild = ''
    export HOME=$(mktemp -d)
    pnpm config set store-dir ${pnpm-deps}
    chmod +w ..
    pnpm install --offline --frozen-lockfile --no-optional --ignore-script
    chmod -R +w ../node_modules
    pnpm rebuild
  '';

  preInstall = ''
    mv target/release/bundle/deb/*/data/usr/ $out
  '';

  meta = with lib; {
    description = "A simple, yet powerful Minecraft custom launcher with a strong focus on the user experience";
    homepage = "https://gdlauncher.com/";
    #changelog = "https://github.com/gorilla-devs/GDLauncher-Carbon/releases/tag/v${version}";
    license = licenses.bsl11;
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
    #mainProgram = "gdlauncher-carbon";
  };
}
