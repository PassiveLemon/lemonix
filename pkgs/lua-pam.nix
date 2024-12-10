{ lib
, stdenv
, fetchFromGitHub
, cmake
, linux-pam
, lua
, nix-update-script
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "lua-pam";
  version = "373de20d6784f77d59abc1ffc1d0302f28ed46cd";

  src = fetchFromGitHub {
    owner = "rmtt";
    repo = "lua-pam";
    rev = finalAttrs.version;
    hash = "sha256-AFCAudWQa3UiNvum4Ir6SY1WhGMaBSjgKyu6jG5efAA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    linux-pam
    lua
  ];

  buildPhase = ''
    runHook preBuild

    cmake . -B build
    cd build
    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp liblua_pam.so $out/lib

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A module for lua to use PAM.";
    homepage = "https://github.com/RMTT/lua-pam/";
    license = licenses.mit;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
  };
})

