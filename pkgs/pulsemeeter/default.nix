{ lib,
  buildPythonApplication,
  fetchFromGitHub,
  setuptools,
  gobject-introspection,
  libayatana-appindicator,
  libpulseaudio,
  pulsectl,
  pygobject3,
  gtk3,
  wrapGAppsHook,
  rnnoise-plugin,
  ladspaPlugins,
  pipewire,
}:

buildPythonApplication rec {
  pname = "pulsemeeter";
  version = "1.2.14";

  src = fetchFromGitHub {
    owner = "theRealCarneiro";
    repo = "pulsemeeter";
    rev = "7405f58daa898fa4ac6c5805c2e82dc984f1875d";
    hash = "sha256-7rjNQQ51lqUXj2POWLtsUoHL1D3FyT9SQWqfkcCHA88=";
  };

  nativeBuildInputs = [
    setuptools
    gobject-introspection
    wrapGAppsHook
  ];
  propagatedBuildInputs = [
    libayatana-appindicator
    pygobject3
    pulsectl
    gtk3
    libpulseaudio
    rnnoise-plugin
    pipewire
    ladspaPlugins
  ];

  patches = [
    ./ayatana.patch
  ];

  meta = with lib; {
    description = "Replicating voicemeeter routing functionalities in linux with pulseaudio";
    homepage = "https://github.com/theRealCarneiro/pulsemeeter";
    #changelog = "https://github.com/theRealCarneiro/pulsemeeter/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ passivelemon ];
    mainProgram = "pulsemeeter";
    broken = true;
  };
}
