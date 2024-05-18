{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  luaPackages,
}:
let
  version = "0-unstable-2023-03-03";
in
stdenvNoCC.mkDerivation {
  pname = "ruler";
  inherit version;

  src = fetchFromGitHub {
    owner = "occivink";
    repo = "mpv-image-viewer";
    rev = "efc8214";
    hash = "sha256-H7uBwrIb5uNEr3m+rHED/hO2CHypGu7hbcRpC30am2Q=";
  };
  dontBuild = true;

  installPhase = ''
    install -Dm644 scripts/ruler.lua $out/share/mpv/scripts/ruler.lua
  '';

  passthru.scriptName = "ruler.lua";

  meta = with lib; {
    description = "Adds a `ruler` command that lets you measure positions, distances and angles in the image";
    homepage = "https://github.com/torque/mpv-image-viewer";
    platforms = platforms.all;
    license = licenses.unlicense;
    maintainers = with maintainers; [ WeraPea ];
  };
}
