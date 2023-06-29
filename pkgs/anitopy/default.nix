{ buildPythonPackage, fetchFromGitHub, lib }:
buildPythonPackage rec {
  pname = "anitopy";
  version = "2.1.1";
  src = fetchFromGitHub {
    owner = "igorcmoura";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-xXEf7AJKg7grDmkKfFuC4Fk6QYFJtezClyfA3vq8TfQ=";
  };

  pythonImportsCheck = [ "anitopy" ];


  meta = with lib; {
    description = "Python library for parsing anime video filenames";
    homepage = "https://github.com/igorcmoura/anitopy";
    license = licenses.mpl20;
    maintainers = with maintainers; [ PassiveLemon ];
  };
}
