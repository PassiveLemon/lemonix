{ lib
, stdenv
, fetchFromGitLab
, fetchpatch
, cmake
, glm
, libGL
, openxr-loader
, python3
, vulkan-headers
, vulkan-loader
, xorg
}:
stdenv.mkDerivation {
  pname = "opencomposite";
  version = "unstable-2024-05-13";

  src = fetchFromGitLab {
    owner = "znixian";
    repo = "OpenOVR";
    rev = "5ddd6024efafa82c7a432c9dd8a67e3d5c3f9b38";
    hash = "sha256-HgbQJl2qo1TAlq84UfJ9JvA5eTVIeRRyvaJeBxQGZAs=";
    #fetchSubmodules = true;
  };

  # A commit (1edb2f37) causes problems when building so I pull the commit before it (5ddd6024) and just patch in the commit after it (bc79a84d)
  # The problematic commit does not appear very useful to regular users
  patches = [
    (fetchpatch {
      url = "https://gitlab.com/znixian/OpenOVR/-/commit/bc79a84d69b1c5a84db3f79c9a0c75278a7aea6f.patch";
      hash = "sha256-oz4z2YCTWrAD86eod2ETL1bDhJcH3mAOixIIb0ce+nM=";
    })
  ];

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    glm
    libGL
    openxr-loader
    python3
    vulkan-headers
    vulkan-loader
    xorg.libX11
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_SYSTEM_OPENXR" true)
    (lib.cmakeBool "USE_SYSTEM_GLM" true)
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/opencomposite
    cp -r bin/ $out/lib/opencomposite

    runHook postInstall
  '';

  meta = with lib; {
    description = "Reimplementation of OpenVR, translating calls to OpenXR";
    homepage = "https://gitlab.com/znixian/OpenOVR";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
  };
}
