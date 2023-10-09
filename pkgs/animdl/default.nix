{ python3Packages,
  buildPythonApplication,
  fetchFromGitHub,
  lib,
  poetry-core,
  click,
  cssselect,
  httpx,
  lxml,
  packaging,
  pkginfo,
  pycryptodomex,
  pyyaml,
  regex,
  rich,
  tqdm,
  yarl
}:
let
  anchor-kr = python3Packages.callPackage ../anchor-kr { };
  anitopy = python3Packages.callPackage ../anitopy { };
in
buildPythonApplication rec {
  pname = "animdl";
  version = "1.7.24";

  src = fetchFromGitHub {
    owner = "justfoolingaround";
    repo = "animdl";
    # Using the commit hash because upstream does not have releases. https://github.com/justfoolingaround/animdl/issues/277
    rev = "08d0c6a2c4d57d7ce342fe6b16955f1570d44849";
    hash = "sha256-/XPVWBitFYsUkb9WMlR5F2amAPcVnDtJUgFXP2gXyNk=";
  };

  format = "pyproject";
  nativeBuildInputs = [
    poetry-core
    cssselect
  ];
  propagatedBuildInputs = [
    anchor-kr
    anitopy
    click
    httpx
    lxml
    packaging
    pkginfo
    pycryptodomex
    pyyaml
    regex
    rich
    tqdm
    yarl
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'pycryptodomex = "~=3.14.1"' 'pycryptodomex = "*"' \
      --replace 'rich = ">=13.3.1,<13.3.4"' 'rich = "*"' \
      --replace 'version = "4.9.1"' 'version = "*"' \
      --replace 'comtypes = "~=1.1.11"' ' '
  '';

  meta = with lib; {
    description = "A highly efficient, powerful and fast anime scraper";
    homepage = "https://github.com/justfoolingaround/animdl";
    license = licenses.gpl3Only;
    mainProgram = "animdl";
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
  };
}
