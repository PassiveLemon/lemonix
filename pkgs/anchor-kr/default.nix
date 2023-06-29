{ buildPythonPackage, fetchFromGitHub, lib }:
buildPythonPackage rec {
  pname = "anchor";
  version = "3";
  src = fetchFromGitHub {
    owner = "justfoolingaround";
    repo = "${pname}";
    rev = "4cedb6a51877ed3a292cad61eb19013382915e86";
    hash = "sha256-t75IFBSz6ncHRqXRxbrM9EQdr8xPXjSd9di+/y2LegE=";
  };

  pythonImportsCheck = [ "anchor" ];


  meta = with lib; {
    description = "Python library for scraping";
    homepage = "https://github.com/justfoolingaround/anchor";
    license = licenses.unfree;
    maintainers = with maintainers; [ PassiveLemon ];
  };
}
