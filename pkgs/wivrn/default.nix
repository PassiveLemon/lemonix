{ config
, lib
, stdenv
, fetchFromGitHub
, fetchFromGitLab
, applyPatches
, autoAddDriverRunpath
, avahi
, bluez
, boost
, cjson
, cli11
, cmake
, cudaPackages ? { }
, cudaSupport ? config.cudaSupport
, dbus
# depthai
, doxygen
, eigen
, elfutils
, ffmpeg
, freetype
, git
, glib
, glm
, glslang
, gst_all_1
, harfbuzz
, hidapi
# leapsdk
# leapv2
, libGL
, libX11
, libXrandr
, libbsd
, libdrm
, libdwg
, libjpeg
, libmd
, libpulseaudio
#, librealsense
, libsurvive
, libunwind
, libusb1
, libuvc
, libva
, nix-update-script
, nlohmann_json
, onnxruntime
, opencv4
, openhmd
, openvr
, openxr-loader
, orc
# percetto
, pipewire
, pkg-config
, python3
, qtbase
, qttools
, SDL2
, shaderc
, spdlog
, systemd
, udev
, vulkan-headers
, vulkan-loader
, wayland
, wayland-protocols
, wayland-scanner
, wrapQtAppsHook
, x264
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wivrn";
  version = "6946d5144a8af5164622d45bb1bc100bf87f640e";

  src = fetchFromGitHub {
    owner = "wivrn";
    repo = "wivrn";
    rev = "${finalAttrs.version}";
    hash = "sha256-GJOBUPtarTVRMHKjdw2igltX0EgIh+IXXfjMHl2DoJg=";
  };

  monado = applyPatches {
    src = fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "monado";
      repo = "monado";
      rev = "01806a3ffa62a2440da83d94e7a9297645d9d95a";
      hash = "sha256-FDWBaT6QaeYZozWHK8c5+GBC+2qQyfUstM+ANt+8POU=";
    };

    patches = [
      ./force-enable-steamvr_lh.patch
    ];

    postPatch = ''
      ${finalAttrs.src}/patches/apply.sh ${finalAttrs.src}/patches/monado
    '';
  };

  strictDeps = true;

  postUnpack = ''
    # Let's make sure our monado source revision matches what is used by WiVRn upstream
    ourMonadoRev="${finalAttrs.monado.src.rev}"
    theirMonadoRev=$(grep "GIT_TAG" ${finalAttrs.src.name}/CMakeLists.txt | awk '{print $2}')
    if [ ! "$theirMonadoRev" == "$ourMonadoRev" ]; then
      echo "Our Monado source revision doesn't match CMakeLists.txt." >&2
      echo "  theirs: $theirMonadoRev" >&2
      echo "    ours: $ourMonadoRev" >&2
      return 1
    fi
  '';

  nativeBuildInputs = [
    cmake
    doxygen
    git
    glib
    glslang
    pkg-config
    python3
    wrapQtAppsHook
  ] ++ lib.optionals cudaSupport [
    autoAddDriverRunpath
  ];

  buildInputs = [
    avahi
    boost
    bluez
    cjson
    cli11
    dbus
    eigen
    elfutils
    ffmpeg
    freetype
    glib
    glm
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    harfbuzz
    hidapi
    libbsd
    libdrm
    libdwg
    libGL
    libjpeg
    libmd
    #librealsense
    libsurvive
    libunwind
    libusb1
    libuvc
    libva
    libX11
    libXrandr
    libpulseaudio
    nlohmann_json
    opencv4
    openhmd
    openvr
    openxr-loader
    onnxruntime
    orc
    pipewire
    qtbase
    qttools
    SDL2
    shaderc
    spdlog
    systemd
    udev
    vulkan-headers
    vulkan-loader
    wayland
    wayland-protocols
    wayland-scanner
    x264
  ] ++ lib.optionals cudaSupport [
    cudaPackages.cudatoolkit
  ];

  cmakeFlags = [
    (lib.cmakeBool "WIVRN_USE_NVENC" cudaSupport)
    (lib.cmakeBool "WIVRN_USE_VAAPI" true)
    (lib.cmakeBool "WIVRN_USE_X264" true)
    (lib.cmakeBool "WIVRN_USE_PIPEWIRE" true)
    (lib.cmakeBool "WIVRN_USE_PULSEAUDIO" true)
    (lib.cmakeBool "WIVRN_USE_SYSTEMD" true)
    (lib.cmakeBool "WIVRN_BUILD_CLIENT" false)
    (lib.cmakeBool "WIVRN_BUILD_DASHBOARD" true)
    (lib.cmakeBool "WIVRN_OPENXR_INSTALL_ABSOLUTE_RUNTIME_PATH" true)
    (lib.cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_MONADO" "${finalAttrs.monado}")
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "An OpenXR streaming application to a standalone headset";
    homepage = "https://github.com/Meumeu/WiVRn/";
    changelog = "https://github.com/Meumeu/WiVRn/releases/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
    mainProgram = "wivrn-server";
  };
})

