{
  fetchFromGitHub,
  libpulseaudio,
  vulkan-loader,
  rustPlatform,
  libxkbcommon,
  makeWrapper,
  pkg-config,
  wayland,
  libGL,
  dbus,
  xorg,
  lib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "librepods";
  version = "0.2.0-linux-rust";

  src = fetchFromGitHub {
    owner = "kavishdevar";
    repo = "librepods";
    # tag = "v${finalAttrs.version}";
    rev = "4737cbfc2c1a4e227e42d095c49ab43bd8d7b64a";
    hash = "sha256-5vPCtjUiFSI/Ix5dbGmR3TGQsYIwWAUHMwx8yH6HXac=";
  };

  sourceRoot = "source/linux-rust";
  cargoHash = "sha256-Ebqx+UU2tdygvqvDGjBSxbkmPnkR47/yL3sCVWo54CU=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libpulseaudio
    dbus

    # Iced-rs dependencies
    vulkan-loader
    libGL
    wayland
    libxkbcommon
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libX11
  ];

  # Allows Iced access to the libraries it needs.
  postFixup = ''
    wrapProgram $out/bin/librepods \
      --suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath finalAttrs.buildInputs}
  '';

  meta = {
    description = "AirPods liberated from Apple's ecosystem.";
    longDescription = ''
      LibrePods unlocks Apple's exclusive AirPods features on non-Apple devices. Get access to noise control modes, adaptive transparency, ear detection, hearing aid, customized transparency mode, battery status, and more - all the premium features you paid for but Apple locked to their ecosystem.
    '';
    homepage = "https://github.com/kavishdevar/librepods/tree/main";
    downloadPage = "https://github.com/kavishdevar/librepods/commit/${finalAttrs.src.rev}";
    # downloadPage = "https://github.com/kavishdevar/librepods/releases/tag/${finalAttrs.src.tag}";
    mainProgram = "librepods";
    license = lib.licenses.gpl3;
    # platforms = ;
    maintainers = [ ];
  };
})

