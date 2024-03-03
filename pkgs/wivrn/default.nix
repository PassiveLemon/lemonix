# WIP. CURRENTLY NOT FUNCTIONAL
{ pkgs ? import <nixpkgs> { system = builtins.currentSystem; },
  lib ? pkgs.lib,
}:

pkgs.stdenv.mkDerivation rec {
  pname = "wivrn";
  version = "0.11";

  src = pkgs.fetchFromGitHub {
    owner = "meumeu";
    repo = "wivrn";
    rev = "v${version}";
    hash = "sha256-E48JYhkBVZfb7S/FW0F8RbMtx4GIJwfXfs4KAF3gn8A=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = with pkgs; [
    avahi
    boost
    cudaPackages.cuda_cudart
    cudaPackages.cuda_nvcc
    eigen
    ffmpeg
    git
    glslang
    libdrm
    libpulseaudio
    monado
    nlohmann_json
    python3
    shaderc
    systemd
    vulkan-headers
    vulkan-loader
    vulkan-tools
    x264
  ];

  cmakeFlags = [
    "-DWIVRN_BUILD_CLIENT=OFF"
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
  ];

  patches = [
    (pkgs.substituteAll {
      src = ./monado.patch;
      monadoSrc = pkgs.monado.src;
    })
  ];

  meta = with lib; {
    description = "An OpenXR streaming application to a standalone headset ";
    homepage = "https://github.com/Meumeu/WiVRn/";
    changelog = "https://github.com/Meumeu/WiVRn/releases/tag/v${version}";
    license = licenses.gpl3;
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wivrn";
  };
}
