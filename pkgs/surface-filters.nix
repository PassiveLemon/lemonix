{ lib
, stdenv
, fetchFromGitHub
, cairo
, gdk-pixbuf
, glib
, gtk3
, luajit
, meson
, ninja
, pkg-config
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "surface-filters";
  version = "b02115863892a19414f9de60e39d4502b3f171a1";

  src = fetchFromGitHub {
    owner = "ReadyWidgets";
    repo = "surface_filters";
    rev = finalAttrs.version;
    hash = "sha256-ckL/NiVTIpTw4Vv7vnXgcMy1pRilWFzcNH8+ZpRXlAw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk3
    luajit
  ];

  buildPhase = ''
    runHook preBuild

    cd /build/source

    meson setup build
    meson compile -C build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp build/surface_filters.so $out/lib

    runHook postInstall
  '';

  meta = with lib; {
    description = "A library to add filter effects to the awesome window manager";
    homepage = "https://github.com/ReadyWidgets/surface_filters/";
    license = licenses.unfree;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
})

