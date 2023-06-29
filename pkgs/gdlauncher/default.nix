{ fetchFromGitHub, buildNpmPackage, pkgs, lib, ... }:
buildNpmPackage rec {
  pname = "gdlauncher";
  version = "1.1.30";
  src = fetchFromGitHub {
    owner = "gorilla-devs";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-TH7k2nnpCOTEsP5Doo2EmWDH9weGrlvcBhymicPkGjs=";
  };
  desiredVersion = "16.13.1";
  nodejs = pkgs.nodejs.overrideAttrs (oldAttrs: {
    version = desiredVersion;
    name = "nodejs-${desiredVersion}";
  });

  nativeBuildInputs = with pkgs; [ gnat13 rustup nodejs (python311.withPackages(ps: with ps; [ distutils_extra ])) ];

  forceGitDeps = true;
  makeCacheWritable = true;

  NODE_OPTIONS = "--openssl-legacy-provider";
  dontNpmBuild = true;

  npmFlags = [ "--legacy-peer-deps" "--ignore-scripts" ];
  npmDepsHash = "sha256-br1Mast/0UYW3nPC/vgkfXDqESbDfEYOwrimU8v+9W0=";
  npmBuildScript = "release";

  #installPhase = ''
  #  
  #'';

  meta = with lib; {
    description = "A simple, yet powerful Minecraft custom launcher with a strong focus on the user experience";
    homepage = "https://gdlauncher.com/";
    changelog = "https://github.com/gorilla-devs/GDLauncher/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ PassiveLemon ];
    platforms = [ "x86_64-linux" ];
  };
}
