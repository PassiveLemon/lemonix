{ lib
, rustPlatform
, fetchFromGitHub
, just
, libdisplay-info
, libgbm
, libGL
, libinput
, libxkbcommon
, lua54Packages
, makeWrapper
, protobuf
, pkg-config
, seatd
, systemd
, vulkan-loader
, wayland
, xorg
, xwayland
}:
# Noteable errors: (Unsure of any possible implications resulting from these)
# ERROR pinnacle: Failed to start xwayland: No such file or directory (os error 2)
# ERROR pinnacle::backend::udev: Skipping device 57857: failed to open device with libseat

rustPlatform.buildRustPackage rec {
  pname = "pinnacle";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "pinnacle-comp";
    repo = "pinnacle";
    rev = "v${version}";
    hash = "sha256-Tc7R5XjQIDZOEv8pJKcv4JgjI0QdPaEUffL7dwL3bfQ=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-YWx0250sagpoyo92FYJPcSc0aTM06vWCBjb0VqmDhR0=";

  strictDeps = true;

  nativeBuildInputs = [
    just
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    libdisplay-info
    libgbm
    libGL
    libinput
    libxkbcommon
    lua54Packages.lua # Needed for mlua
    protobuf
    seatd
    systemd
    vulkan-loader
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    xwayland
  ];

  dontUseJustBuild = true;
  dontUseJustInstall = true;

  # Every test will fail without it:
  # Error: could not load libwayland-server.so
  doCheck = false;

  env.PROTOC = lib.getExe protobuf;

  postFixup = ''
    wrapProgram $out/bin/pinnacle \
      --suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
  '';

  meta = with lib; {
    description = "A WIP Smithay-based Wayland compositor, inspired by AwesomeWM and configured in Lua or Rust";
    homepage = "https://github.com/pinnacle-comp/pinnacle";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
    mainProgram = "pinnacle";
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}

