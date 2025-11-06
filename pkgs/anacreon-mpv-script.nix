{
  lib,
  buildLua,
  fetchFromGitHub,
  wl-clipboard,
  xclip,
  curl,
}:
let
  version = "1.0.1";
in
buildLua {
  pname = "anacreon-mpv-script";
  inherit version;
  scriptPath = "./animecards";

  src = fetchFromGitHub {
    owner = "friedrich-de";
    repo = "Anacreon-Script";
    tag = "v${version}";
    hash = "sha256-2cpCHA32z4N8reQV5QjdXQc3mWX5Z6Cr/CMZp2VlqVY=";
  };

  postPatch = ''
    substituteInPlace animecards/clipboard.lua \
      --replace-fail 'wl-copy' "${lib.getExe' wl-clipboard "wl-copy"}" \
      --replace-fail 'wl-paste' "${lib.getExe' wl-clipboard "wl-paste"}" \
      --replace-fail 'xclip' "${lib.getExe xclip}"
    substituteInPlace animecards/anki.lua \
      --replace-fail 'curl' "${lib.getExe curl}"
  '';

  meta = with lib; {
    description = "Anacreon MPV script";
    homepage = "https://github.com/friedrich-de/Anacreon-Script";
    platforms = platforms.linux;
    license = licenses.unfree; # no license
  };
}
