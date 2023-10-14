{ buildPythonApplication,
  fetchFromGitHub,
  lib,
  setuptools,
  zeroconf,
  pycryptodomex
}:
buildPythonApplication rec {
  pname = "onthespot";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "casualsnek";
    repo = "onthespot";
    rev = "v${version}";
    hash = "sha256-VaJBNsT7uNOGY43GnzhUqDQNiPoFZcc2UaIfOKgkufg=";
  };

  format = "pyproject";
  nativeBuildInputs = [
    setuptools
    zeroconf
  ];
  propagatedBuildInputs = [
    zeroconf
    pycryptodomex
  ];

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace 'zeroconf==0.62.0' 'zeroconf~=0.62.0'
  '';

  meta = with lib; {
    description = "qt based music downloader written in python";
    homepage = "https://github.com/casualsnek/onthespot";
    license = licenses.gpl2Only;
    mainProgram = "onthespot";
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
  };
}
