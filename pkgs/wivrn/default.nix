{ lib
, stdenv
, fetchFromGitHub
, fetchFromGitLab
, avahi
, boost
, cmake
, cudaPackages
, eigen
, ffmpeg
, freetype
, git
, glm
, glslang
, harfbuzz
, libdrm
, libva
, libpulseaudio
, libX11
, libXrandr
, nlohmann_json
, onnxruntime
, openxr-loader
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
  version = "0.13";

  src = fetchFromGitHub {
    owner = "meumeu";
    repo = "wivrn";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Xg2LRwPh0DbvrwPHno646TndM+JVoRz7I8DIM4c7uHs=";
  };

  monadoSrc = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "monado";
    repo = "monado";
    # Version stated in CMakeList for WiVRn 0.13
    rev = "ffb71af26f8349952f5f820c268ee4774613e200";
    hash = "sha256-+RTHS9ShicuzhiAVAXf38V6k4SVr+Bc2xUjpRWZoB0c=";
  };

  # The library path to the OpenXR runtime requires a relative path from the config file to the binary in the nix store
  # The CMakeList has relative directory paths that cause malformation of the path. https://github.com/Meumeu/WiVRn/issues/47
  # What it is: ../../..//nix/store/...
  # What we want: /nix/store/...
  patchPhase = ''
    substituteInPlace ./server/CMakeLists.txt \
      --replace "../../../" ""
  '';

  nativeBuildInputs = [
    cmake
    cudaPackages.cuda_nvcc
    git
    pkg-config
    python3
  ];

  buildInputs = [
    avahi
    boost
    cudaPackages.cuda_cudart
    eigen
    ffmpeg
    freetype
    glm
    glslang
    harfbuzz
    libdrm
    libva
    libX11
    libXrandr
    libpulseaudio
    nlohmann_json
    onnxruntime
    openxr-loader
    shaderc
    spdlog
    systemd
    udev
    vulkan-headers
    vulkan-loader
    vulkan-tools
    x264
  ];

  cmakeFlags = [
    (lib.cmakeBool "WIVRN_BUILD_CLIENT" false)
    (lib.cmakeBool "WIVRN_USE_VAAPI" true)
    (lib.cmakeBool "WIVRN_USE_X264" true)
    (lib.cmakeBool "WIVRN_USE_NVENC" false)
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
