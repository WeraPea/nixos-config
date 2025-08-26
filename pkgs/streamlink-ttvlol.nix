{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "streamlink-ttvlol";
  version = "7.5.0-20250709";

  src = fetchFromGitHub {
    owner = "2bc4";
    repo = "streamlink-ttvlol";
    rev = version;
    hash = "sha256-SXTu5qDlUNP158w4/Sq7CU7plpSka7uiUCgyDLw8ICM=";
  };

  installPhase = ''
    install -Dm644 ./twitch.py $out
  '';

  meta = {
    description = "Streamlink Twitch plugin modified to work with the TTV.LOL API";
    homepage = "https://github.com/2bc4/streamlink-ttvlol/releases";
    license = lib.licenses.bsd2;
    mainProgram = "streamlink-ttvlol";
    platforms = lib.platforms.all;
  };
}
