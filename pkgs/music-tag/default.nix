{ lib,
  buildPythonPackage,
  fetchFromGitHub,
  mutagen,
  pillow
}:
buildPythonPackage rec {
  pname = "music-tag";
  version = "0.4.3";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "KristoforMaynard";
    repo = "music-tag";
    # Upstream does not have releases.
    rev = "79d07c4792d11ee53e84fe48aff2789ec3b5e5d6";
    hash = "sha256-8i6sLSv7wWOIXbdSfnLVTLRCyziJWehdTYrz5irLpdI=";
  };

  nativeBuildInputs = [
    mutagen
  ];
  propagatedBuildInputs = [
    pillow
  ];

  pythonImportsCheck = [ "music_tag" ];
  doCheck = true;

  meta = with lib; {
    description = "Simple interface to edit audio file metadata ";
    homepage = "https://github.com/KristoforMaynard/music-tag";
    license = licenses.mit;
    maintainers = with maintainers; [ passivelemon ];
  };
}
