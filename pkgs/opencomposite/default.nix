{ lib
, stdenv
, fetchFromGitHub
, fetchFromGitLab
, cmake
, glm
, libGL
, python3
, vulkan-headers
, vulkan-loader
, xorg
, unstableGitUpdater
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "opencomposite";
  version = "0-unstable-2024-05-24";

  src = fetchFromGitLab {
    owner = "znixian";
    repo = "OpenOVR";
    rev = "2a369ef4a917e5edd4b166881e33a62558ed069e";
    hash = "sha256-PrbBFciwtRDf/s7SCBoltnnhnJ17aQsnn7m4OccMEj4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    glm
    libGL
    python3
    vulkan-headers
    vulkan-loader
    xorg.libX11
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_SYSTEM_OPENXR" false) #https://gitlab.com/znixian/OpenOVR/-/issues/416
    (lib.cmakeBool "USE_SYSTEM_GLM" true)
    # debug logging macros cause format-security warnings
    (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-Wno-error=format-security")
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/opencomposite
    cp -r bin/ $out/lib/opencomposite

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    hardcodeZeroVersion = true;
    branch = "openxr";
  };

  meta = with lib; {
    description = "Reimplementation of OpenVR, translating calls to OpenXR";
    homepage = "https://gitlab.com/znixian/OpenOVR";
    license = with licenses; [ gpl3Only ];
    maintainers = with maintainers; [ Scrumplex ];
  };
})
