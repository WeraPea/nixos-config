{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "streamlink-ttvlol";
  version = "6.8.2-20240705";

  src = fetchFromGitHub {
    owner = "2bc4";
    repo = "streamlink-ttvlol";
    rev = version;
    hash = "sha256-d+gSUE+6PfyiE9NlawHk66SS5A3kW9W2Dqy8epUkJKk=";
  };

  installPhase = ''
    install -Dm644 ./twitch.py $out
  '';

  meta = {
    description = "Streamlink Twitch plugin modified to work with the TTV.LOL API";
    homepage = "https://github.com/2bc4/streamlink-ttvlol/releases";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ WeraPea ];
    mainProgram = "streamlink-ttvlol";
    platforms = lib.platforms.all;
  };
}
