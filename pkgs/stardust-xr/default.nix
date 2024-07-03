# https://github.com/NixOS/nixpkgs/pull/324375

{
  lib,
  fetchFromGitHub,
  writeScript,
  gitUpdater,
  rustPlatform,
  openxr-loader,
  libGL,
  mesa,
  xorg,
  fontconfig,
  libxkbcommon,
  libclang,
  cmake,
  cpm-cmake,
  pkg-config,
  llvmPackages,
}:

rustPlatform.buildRustPackage rec {
  pname = "stardust-xr-server";
  version = "0.44.1";

  src = fetchFromGitHub {
    owner = "stardustxr";
    repo = "server";
    rev = "refs/tags/${version}";
    hash = "sha256-sCatpWDdy7NFWOWUARjN3fZMDVviX2iV79G0HTxfYZU=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "smithay-0.3.0" = "sha256-dxAgTGW+xxnL+vA6j2Ng02F1zt/Y5VaSxP9xg8jfMy8=";
      "stardust-xr-0.14.1" = "sha256-fmRb46s0Ec8wnoerBh4JCv1WKz2of1YW+YGwy0Gr/yQ=";
    };
  };
  nativeBuildInputs = [
    cmake
    pkg-config
    llvmPackages.libcxxClang
  ];
  buildInputs = [
    openxr-loader
    libGL
    mesa
    xorg.libX11
    fontconfig
    libxkbcommon
  ];

  LIBCLANG_PATH = "${libclang.lib}/lib";
  CPM_SOURCE_CACHE = "./build";

  postPatch = ''
    sk=$(echo $cargoDepsCopy/stereokit-sys-*/StereoKit)
    mkdir -p $sk/build/cpm

    # This is not ideal, the original approach was to fetch the exact cmake
    # file version that was wanted from GitHub directly, but at least this way it comes from Nixpkgs.. so meh
    cp ${cpm-cmake}/share/cpm/CPM.cmake $sk/build/cpm/CPM_0.32.2.cmake
  '';

  passthru.updateScript = writeScript "envision-update" ''
    source ${builtins.head (gitUpdater { })}
    cp $tmpdir/Cargo.lock ./pkgs/by-name/en/envision-unwrapped/Cargo.lock
  '';

  meta = {
    description = "A wayland compositor and display server for 3D applications";
    homepage = "https://stardustxr.org";
    license = lib.licenses.gpl2Plus;
    mainProgram = "stardust-xr-server";
    maintainers = with lib.maintainers; [ pandapip1 ];
    platforms = lib.platforms.linux;
  };
}
