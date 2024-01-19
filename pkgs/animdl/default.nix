{ lib,
  buildPythonApplication,
  fetchFromGitHub,
  poetry-core,
  anchor-kr,
  anitopy,
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
buildPythonApplication {
  pname = "animdl";
  version = "1.7.27";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "justfoolingaround";
    repo = "animdl";
    # Using the commit hash because upstream does not have releases. https://github.com/justfoolingaround/animdl/issues/277
    rev = "c7c3b79198e66695e0bbbc576f9d9b788616957f";
    hash = "sha256-kn6vCCFhJNlruxoO+PTHVIwTf1E5j1aSdBhrFuGzUq4=";
  };

  nativeBuildInputs = [
    poetry-core
  ];
  propagatedBuildInputs = [
    anchor-kr
    anitopy
    click
    cssselect
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

  postConfigure = ''
    substituteInPlace pyproject.toml \
      --replace 'comtypes = "~=1.1.11"' "" \
      --replace 'httpx = "~=0.23.0"' 'httpx = ">=0.23.0"' \
      --replace 'pycryptodomex = "~=3.14.1"' 'pycryptodomex = ">=3.14.1"' \
      --replace 'regex = "~=2022.10.31"' 'regex = ">=2022.10.31"' \
      --replace 'rich = ">=13.3.1,<13.3.4"' 'rich = ">=13.3.1"' \
      --replace 'tqdm = ">=4.62.3,<4.66.0"' 'tqdm = ">=4.62.3"' \
      --replace 'yarl = "~=1.8.1"' 'yarl = ">=1.8.1"' \
      --replace 'version = "4.9.1"' 'version = ">=4.9.1"' #lxml
  '';

  doCheck = true;

  meta = with lib; {
    description = "A highly efficient, powerful and fast anime scraper";
    homepage = "https://github.com/justfoolingaround/animdl";
    license = licenses.gpl3Only;
    mainProgram = "animdl";
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
  };
}
