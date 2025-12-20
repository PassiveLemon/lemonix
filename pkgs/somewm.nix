{ lib
, stdenv
, fetchFromGitHub
, cairo
, dbus
, gdk-pixbuf
, glib
, gobject-introspection
, libdrm
, libinput
, librsvg
, libxcb-util
, libxcb-wm
, libxkbcommon
, luajit
, makeWrapper
, pango
, pkg-config
, wayland
, wayland-scanner
, wayland-protocols
, wlroots_0_19
, xwayland
, gtk3Support ? false
, gtk3 ? null
, additionalLuaPackages ? [ ]
, additionalLuaCPATH ? ""
}:

assert gtk3Support -> gtk3 != null;

let
  luaEnv = luajit.withPackages (ps: with ps; ([
    lgi
  ] ++ additionalLuaPackages));
in
stdenv.mkDerivation (finalAttrs: {
  pname = "somewm";
  version = "bb70b2d2cef1f4f5daea811ed8c6ab7817e8819e";

  src = fetchFromGitHub {
    owner = "trip-zip";
    repo = "somewm";
    rev = finalAttrs.version;
    hash = "sha256-Oe4BRWVUIOq5qJwx7KqvlSg/ec9oO6kl1C6Cuu7XtJs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gobject-introspection
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    cairo
    dbus
    gdk-pixbuf
    glib
    libdrm
    libinput
    librsvg
    libxcb-util
    libxcb-wm
    libxkbcommon
    luajit
    luaEnv
    pango
    wayland
    wayland-scanner
    wayland-protocols
    wlroots_0_19
    xwayland
  ] ++ lib.optional gtk3Support gtk3;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin/
    install -m755 somewm $out/bin/somewm
    install -m755 somewm-client $out/bin/somewm-client

    #mkdir -p $out/share/wayland-sessions/
    #install -m644 somewm.desktop $out/share/wayland-sessions/somewm.desktop

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/somewm \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --set LUA_CPATH "${luaEnv}/lib/lua/${luaEnv.luaversion}/?.so;${additionalLuaCPATH};;" \
      --set LUA_PATH "${finalAttrs.src}/lua/?/init.lua;${finalAttrs.src}/lua/?.lua;${luaEnv}/share/lua/${luaEnv.luaversion}/?.lua;;" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH"
  '';

  meta = with lib; {
    description = "A Wayland compositor that brings AwesomeWM's Lua API to Wayland";
    homepage = "https://github.com/trip-zip/somewm/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = "somewm";
  };
})

