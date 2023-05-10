{ stdenv, lib, fetchurl, unzip, ... }:
# Define your module options and defaults here
stdenv.mkDerivation rec {
  pname = "lemonwalls";

  src = fetchurl {
    url = "https://github.com/PassiveLemon/lemonwalls/archive/refs/heads/master.zip";
    sha256 = "14ixjy80zhx1liqbf6dx647j58l32iy37daa7n04y0dchx0rz2aw";
  };

  # Extract the ZIP file and copy its contents to the user's home directory
  installPhase = ''
    unzip master.zip -d ./lemonwalls/
    mkdir -p /home/lemon/.wallpapers/
    cp -r lemonwalls/ /home/lemon/.wallpapers/
  '';
}