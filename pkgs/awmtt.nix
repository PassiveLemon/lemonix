{ fetchFromGitHub
, writeShellApplication
, inotify-tools
, xorg
}:
let
  src = fetchFromGitHub {
    owner = "gmdfalk";
    repo = "awmtt";
    rev = "92ababc7616bff1a7ac0a8e75e0d20a37c1e551e";
    hash = "sha256-3IpCuLIdN4t4FzFSHAlJ9FW9Y8UcWIqXG9DfiAwZoMY=";
  };
in
writeShellApplication {
  name = "awmtt";
  runtimeInputs = [ xorg.xorgserver inotify-tools ];
  text = ''
    set +u
    ${builtins.readFile "${src}/awmtt.sh"}
  '';
  checkPhase = "";
}

