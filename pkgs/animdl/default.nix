{ pkgs, ... }:
let
  src = pkgs.fetchFromGitHub {
    owner = "justfoolingaround";
    repo = "animdl";
    rev = "fd3277fb919c4b5e7ef42daba0bd001695a9c124";
    hash = "sha256-pgtrStorkIJJ3oIGgRjNWYwcQ5jUC8IS5iI9CyDJkzE=";
  };
in
pkgs.poetry2nix.mkPoetryApplication {
  projectDir = src;
  overrides = pkgs.poetry2nix.defaultPoetryOverrides.extend (self: super: {
    comtypes = super.comtypes.overridePythonAttrs
      ( old: { buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ]; });
    anitopy = super.anitopy.overridePythonAttrs
      ( old: { buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ]; });
    anchor-kr = super.anchor-kr.overridePythonAttrs
      ( old: { buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ]; });
  });
}