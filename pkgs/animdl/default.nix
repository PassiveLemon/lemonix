{ python3Packages, buildPythonApplication, fetchFromGitHub, lib,
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
  version = "1.7.17";
  src = fetchFromGitHub {
    owner = "justfoolingaround";
    repo = "animdl";
    rev = "fd3277fb919c4b5e7ef42daba0bd001695a9c124";
    hash = "sha256-pgtrStorkIJJ3oIGgRjNWYwcQ5jUC8IS5iI9CyDJkzE=";
  };
  format = "pyproject";
  nativeBuildInputs = [ poetry-core cssselect ];
  propagatedBuildInputs = [ anchor-kr anitopy click httpx lxml packaging pkginfo pyyaml pycryptodomex regex rich tqdm yarl ];

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
    maintainers = with maintainers; [ PassiveLemon ];
    platforms = [ "x86_64-linux" ];
  };
}
