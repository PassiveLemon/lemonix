{ lib
, stdenv
, fetchFromGitLab
, cmake
, vulkan-headers
, vulkan-loader
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "monado-vulkan-layers";
  version = "ae43cdcbd25c56e3481bbc8a0ce2bfcebba9f7c2";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "monado";
    repo = "utilities/vulkan-layers";
    rev = finalAttrs.version;
    sha256 = "sha256-QabYVKcenW+LQ+QSjUoQOLOQAVHdjE0YXd+1WsdzNPc=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    vulkan-headers
    vulkan-loader
  ];

  meta = with lib; {
    description = "Vulkan Layers for Monado";
    homepage = "https://gitlab.freedesktop.org/monado/utilities/vulkan-layers";
    platforms = platforms.linux;
    license = licenses.boost;
    maintainers = with maintainers; [ passivelemon ];
  };
})
