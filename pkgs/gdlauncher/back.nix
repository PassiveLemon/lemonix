{ pkgs, lib, ... }:
let
  pname = "gdlauncher";
  version = "1.1.30";
  src = pkgs.fetchFromGitHub {
    owner = "gorilla-devs";
    repo = "gdlauncher";
    rev = "v${version}";
    hash = "sha256-ALGvJAzDqgzuS8cSyl24sSXmUGlQ8PCfnf6iixc7bTM=";
  };
in
pkgs.stdenvNoCC.mkDerivation rec {
  inherit pame version src;

  buildInputs = with pkgs; [ gnat13 rustup nodejs_16 (python311.withPackages(ps: with ps; [ distutils_extra ])) ];

  #propagatedBuildInputs = [
  #  pkgs.fetchurl {
  #    url = "https://static.rust-lang.org/rustup/dist/${pkgs.stdenv.system}/rustup-init";
  #    hash = "";
  #  } ./rustup-init
  #];

  buildPhase = ''
    export HOME=$(pwd)
    #./rustup-init -y --default-toolchain nightly
    export ELECTRON_SKIP_BINARY_DOWNLOAD=1
    npm config set registry https://registry.npmjs.org/ --global
    npm set progress=false
    npm install pnpm
    pnpm install
    pnpm run release
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp gdlauncher $out/bin
  '';

  meta = with lib; {
    description = "A simple, yet powerful Minecraft custom launcher with a strong focus on the user experience";
    homepage = "https://gdlauncher.com/";
    changelog = "https://github.com/gorilla-devs/GDLauncher/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ "PassiveLemon" ];
    platforms = [ "x86_64-linux" ];
  };
}
