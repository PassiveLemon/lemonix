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
}:
let
  vendorMonado = monado.overrideAttrs rec {
    # Version stated in CMakeList for WiVRn 0.11
    version = "57e937383967c7e7b38b5de71297c8f537a2489d";

    src = fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "monado";
      repo = "monado";
      rev = version;
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

  # The library path to the OpenXR runtime requires a relative path from the config file to the binary in the nix store
  # The config file is usually located at ~/.config/openxr/1/ but the wivrn module puts it at /etc/xdg/openxr/1/
  # The CMakeList has relative directory paths that cause malformation of the path. https://github.com/Meumeu/WiVRn/issues/47
  # What it is: ../../..//nix/store/...
  # What it should be: ../../../../nix/store/...
  # Details about the required path here (Section 3): https://monado.freedesktop.org/valve-index-setup.html
  patchPhase = ''
    substituteInPlace ./server/CMakeLists.txt \
      --replace "../../../" "../../../.."
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
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_MONADO" "${vendorMonado.src}")
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
}
