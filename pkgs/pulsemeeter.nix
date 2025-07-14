{
  lib,
  python3,
  fetchFromGitHub,
  libappindicator,
  libpulseaudio,
  gobject-introspection,
  wrapGAppsHook4,
  ladspaPlugins,
  bash,
# noise-suppression-for-voice,
# pulse-vumeter,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pulsemeeter";
  version = "128cf16e6d295f5b4fa78ea13b587beea4fae52c";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "theRealCarneiro";
    repo = "pulsemeeter";
    rev = version;
    hash = "sha256-sYO6cdtZHxhhKJf/blXkUHjmOZdZXRwQ2IhSyQsl7qk=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    bash
    libappindicator
    libpulseaudio
  ];

  dependencies = with python3.pkgs; [
    pulsectl
    pulsectl-asyncio
    pydantic
    pygobject3
  ];

  pythonImportsCheck = [
    "pulsemeeter"
  ];

  dontWrapGApps = true;
  # Arguments to be passed to `makeWrapper`, only used by buildPython*
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postPatch = ''
    substituteInPlace src/scripts/pmctl \
      --replace-fail '/usr/lib$lib/ladspa' '${ladspaPlugins}/lib/ladspa'
  '';

  meta = {
    description = "Replicating voicemeeter routing functionalities in linux with pulseaudio";
    homepage = "https://github.com/theRealCarneiro/pulsemeeter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sandptel ];
    mainProgram = "pulsemeeter";
  };
}

