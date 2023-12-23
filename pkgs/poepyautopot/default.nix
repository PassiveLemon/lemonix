{ lib
, buildPythonApplication
, fetchFromGitHub
, colorama
, evdev
, pillow
, pynput
, pyyaml
, setuptools
}:

buildPythonApplication rec {
  pname = "poepyautopot";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "passivelemon";
    repo = "poepyautopot";
    rev = "${version}";
    hash = "sha256-K0e3E0Ba0Hm+L6ofJ0Dj0RNgW/QFsPR1gRxvFeR8Ysc=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    colorama
    evdev
    pillow
    pynput
    pyyaml
  ];

  doCheck = false;

  meta = with lib; {
    description = "A Python based Autopot script for Path of Exile";
    homepage = "https://github.com/passiveLemon/poepyautopot";
    changelog = "https://github.com/passiveLemon/poepyautopot/releases/tag/${version}";
    license = licenses.gpl3;
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
  };
}
