{ lib
, stdenv
, fetchFromGitHub
, fetchgit
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
, monado
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
, xorg
}:
let
  vendorMonado = monado.overrideAttrs rec {
    # Version stated in CMakeList for WiVRn 0.11
    version = "57e937383967c7e7b38b5de71297c8f537a2489d";

    src = fetchgit {
      url = "https://gitlab.freedesktop.org/monado/monado.git";
      rev = "${version}";
      hash = "sha256-O/Td2WccTr4Fa8U64/lVfnidSIH5t3gWuFXCsEVf7bk=";
    };

    postInstall = ''
      mv src/xrt/compositor/libcomp_main.a $out/lib/libcomp_main.a
    '';
  };
in
stdenv.mkDerivation rec {
  pname = "wivrn";
  version = "0.11";

  src = fetchFromGitHub {
    owner = "meumeu";
    repo = "wivrn";
    rev = "v${version}";
    hash = "sha256-E48JYhkBVZfb7S/FW0F8RbMtx4GIJwfXfs4KAF3gn8A=";
  };

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
    xorg.libX11
    xorg.libXrandr
  ];

  cmakeFlags = [
    (lib.cmakeBool "WIVRN_BUILD_CLIENT" false)
    (lib.cmakeBool "WIVRN_USE_VAAPI" true)
    (lib.cmakeBool "WIVRN_USE_X264" true)
    (lib.cmakeBool "WIVRN_USE_NVENC" false)
    (lib.cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_MONADO" "${vendorMonado.src}")
  ];

  postFixup = ''
    substituteInPlace $out/share/openxr/1/openxr_wivrn.json --replace "../../../" "../../../../.."
  '';

  meta = with lib; {
    description = "An OpenXR streaming application to a standalone headset";
    homepage = "https://github.com/Meumeu/WiVRn/";
    changelog = "https://github.com/Meumeu/WiVRn/releases/tag/v${version}";
    license = licenses.gpl3;
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wivrn-server";
  };
}
