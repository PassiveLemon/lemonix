{ lib
, stdenv
, fetchFromGitHub
, fetchFromGitLab
, fetchpatch
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
  version = "0-unstable-2024-06-11";

  src = fetchFromGitLab {
    owner = "znixian";
    repo = "OpenOVR";
    rev = "863c7843bafb385fa747d6ba109ad2fdd3b36b29";
    hash = "sha256-gVqtQwdFaDmuP7xwPle6WeQ6kpHc3aVBV2RgI2H8+Y8=";
    fetchSubmodules = true;
  };

  # https://gitlab.com/znixian/OpenOVR/-/merge_requests/118
  patches = [
    (fetchpatch {
      name = "pull-missing-action-manifest-path-from-steams-appinfo-vdf";
      url = "https://gitlab.com/Supreeeme/OpenOVR/-/commit/336f4007d4e69f2651553fe0f98a0605216c415c.patch";
      hash = "sha256-l2qx9LPGIX1VFmKjJNVKcHeFwjLgD9fzv0KbQ0WXQYc=";
    })
    (fetchpatch {
      name = "reset-overlay-compositors-after-a-session-restart";
      url = "https://gitlab.com/Supreeeme/OpenOVR/-/commit/de1658db7e2535fd36c2e37fa8dd3d756280c86f.patch";
      hash = "sha256-knlDamcghRYT2rEazi+b4Oz7V4RWMFqERhdKZafMWfs=";
    })
  ];

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
