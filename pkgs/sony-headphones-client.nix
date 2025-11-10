{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  bluez,
  dbus,
  glew,
  glfw,
  imgui,
  xorg,
  libxcursor,
  libxrandr,
  makeDesktopItem,
  copyDesktopItems,
}:

stdenv.mkDerivation {
  pname = "SonyHeadphonesClient";
  version = "unstable-2025-10-04";

  src = fetchFromGitHub {
    owner = "mos9527";
    repo = "SonyHeadphonesClient";
    rev = "030f44bffdfe1d98917a9bf126ef3c1258ce27d6";
    hash = "sha256-6aR8RNocByBCtVTVfALlgBQ6q7JGclII3WVMd3a0+uc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    copyDesktopItems
  ];
  buildInputs = [
    bluez
    dbus
    glew
    glfw
    imgui
    xorg.libX11
    xorg.libXinerama
    xorg.libXi
    libxcursor
    libxrandr
  ];

  cmakeFlags = [ "-Wno-dev" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin SonyHeadphonesClient
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "SonyHeadphonesClient";
      exec = "SonyHeadphonesClient";
      icon = "SonyHeadphonesClient";
      desktopName = "Sony Headphones Client";
      comment = "A client recreating the functionality of the Sony Headphones app";
      categories = [
        "Audio"
        "Mixer"
      ];
    })
  ];

  meta = with lib; {
    description = "Client recreating the functionality of the Sony Headphones app";
    homepage = "https://github.com/Plutoberth/SonyHeadphonesClient";
    license = licenses.mit;
    maintainers = with maintainers; [ stunkymonkey ];
    platforms = platforms.linux;
    mainProgram = "SonyHeadphonesClient";
  };
}
