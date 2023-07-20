{ fetchFromGitHub, buildGoModule, lib }:
buildGoModule rec {
  pname = "corrupter";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "r00tman";
    repo = "corrupter";
    # Upstream does provide a release but it cannot be built due to missing go.mod. This commit has it. https://github.com/r00tman/corrupter/issues/15
    rev = "d7aecbb8b622a2c6fafe7baea5f718b46155be15";
    sha256 = "sha256-GEia3wZqI/j7/dpBbL1SQLkOXZqEwanKGM4wY9nLIqE=";
  };

  vendorHash = null;

  meta = with lib; {
    description = "Simple image glitcher";
    homepage = "https://github.com/r00tman/corrupter";
    license = licenses.bsd2;
    maintainers = with maintainers; [ PassiveLemon ];
    platforms = [ "x86_64-linux" ];
  };
}
