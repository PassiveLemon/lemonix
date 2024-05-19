{ config
, lib
, stdenv
, fetchFromGitHub
, fetchFromGitLab
, fetchpatch
, avahi
, boost
, cmake
, cudaPackages ? { }
, cudaSupport ? config.cudaSupport
, eigen
, ffmpeg
, freetype
, git
, glm
, glslang
, harfbuzz
, libdrm
, libGL
, libva
, libpulseaudio
, libX11
, libXrandr
, nlohmann_json
, onnxruntime
, openxr-loader
, pipewire
, pkg-config
, python3
, shaderc
, spdlog
, systemd
, udev
, vulkan-headers
, vulkan-loader
, vulkan-tools
, x264
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wivrn";
  version = "0.15";

  src = fetchFromGitHub {
    owner = "meumeu";
    repo = "wivrn";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RVRbL9hqy9pMKjvzwaP+9HGEfdpAhmlnnvqZsEGxlCw=";
  };

  monadoSrc = stdenv.mkDerivation (finalAttrs: {
    pname = "monado";
    # Version stated in CMakeList for WiVRn 0.15
    version = "ffb71af26f8349952f5f820c268ee4774613e200";

    src = fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "monado";
      repo = "monado";
      rev = finalAttrs.version;
      hash = "sha256-+RTHS9ShicuzhiAVAXf38V6k4SVr+Bc2xUjpRWZoB0c=";
    };

    patches = [
      (fetchpatch {
        name = "0001-c-multi-disable-dropping-of-old-frames.patch";
        url = "https://raw.githubusercontent.com/Meumeu/WiVRn/master/patches/monado/0001-c-multi-disable-dropping-of-old-frames.patch";
        hash = "sha256-/m0idwukz1jEGkoZ1KDwXQXxbqdbVq4I7F6clnHp+YM=";
      })
      (fetchpatch {
        name = "0002-ipc-server-Always-listen-to-stdin.patch";
        url = "https://raw.githubusercontent.com/Meumeu/WiVRn/master/patches/monado/0002-ipc-server-Always-listen-to-stdin.patch";
        hash = "sha256-hAZffrYu3I3RcvQ62IwedKa5DyvJ3Ws6ghbnGgEVxVw=";
      })
      (fetchpatch {
        name = "0003-c-multi-Don-t-log-frame-time-diff.patch";
        url = "https://raw.githubusercontent.com/Meumeu/WiVRn/master/patches/monado/0003-c-multi-Don-t-log-frame-time-diff.patch";
        hash = "sha256-jZWS1IBo1/PyUpRfMt2A8/8f3zcFn3f9wAxMRgLA+cE=";
      })
    ];

    postPatch = ''
      substituteInPlace CMakeLists.txt \
        --replace "add_subdirectory(doc)" ""
    '';

    dontBuild = true;

    installPhase = "cp -r . $out";
  });

  nativeBuildInputs = [
    cmake
    git
    pkg-config
    python3
  ] ++ lib.optionals cudaSupport [
    cudaPackages.autoAddOpenGLRunpathHook
  ];

  buildInputs = [
    avahi
    boost
    eigen
    ffmpeg
    freetype
    glm
    glslang
    harfbuzz
    libdrm
    libGL
    libva
    libX11
    libXrandr
    libpulseaudio
    nlohmann_json
    onnxruntime
    openxr-loader
    pipewire
    shaderc
    spdlog
    systemd
    udev
    vulkan-headers
    vulkan-loader
    vulkan-tools
    x264
  ] ++ lib.optionals cudaSupport [
    cudaPackages.cudatoolkit
  ];

  cmakeFlags = [
    (lib.cmakeBool "WIVRN_BUILD_CLIENT" false)
    (lib.cmakeBool "WIVRN_USE_VAAPI" true)
    (lib.cmakeBool "WIVRN_USE_X264" true)
    (lib.cmakeBool "WIVRN_USE_NVENC" cudaSupport)
    (lib.cmakeBool "WIVRN_OPENXR_INSTALL_ABSOLUTE_RUNTIME_PATH" true)
    (lib.cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_MONADO" "${finalAttrs.monadoSrc}")
  ];

  meta = with lib; {
    description = "An OpenXR streaming application to a standalone headset";
    homepage = "https://github.com/Meumeu/WiVRn/";
    changelog = "https://github.com/Meumeu/WiVRn/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
    mainProgram = "wivrn-server";
  };
})
