{ lib
, python3
, fetchFromGitHub
, cairosvg
, gtk3
, libappindicator
, meson
, ninja
, pkg-config
}:
python3.pkgs.buildPythonApplication rec {
  pname = "hardcode-tray";
  version = "4.3";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "bilelmoussaoui";
    repo = "Hardcode-Tray";
    rev = "v${version}";
    hash = "sha256-VY2pySi/sCqc9Mx+azj2fR3a46w+fcmPuK+jTBj9018=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gtk3
    libappindicator
  ];

  # Doesn't run:
  # ValueError: Namespace Gtk not available
  dependencies = with python3.pkgs; [
    cairosvg
    pygobject3
  ];

  meta = with lib; {
    description = "Fixes Hardcoded tray icons in Linux";
    homepage = "https://github.com/bilelmoussaoui/Hardcode-Tray/";
    changelog = "https://github.com/bilelmoussaoui/Hardcode-Tray/releases/";
    license = licenses.bsd2;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
    mainProgram = "hardcode-tray";
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}

