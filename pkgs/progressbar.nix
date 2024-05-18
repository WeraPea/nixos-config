{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  luaPackages,
}:
let
  version = "2023.11.04.0";
in
stdenvNoCC.mkDerivation {
  pname = "progressbar";
  inherit version;

  src = fetchFromGitHub {
    owner = "torque";
    repo = "mpv-progressbar";
    rev = "${version}";
    hash = "sha256-mJRYQQB2NaHMXD9/agtReA2Uyfi1tPp6FS1fKUITfKM=";
  };
  buildInputs = [ luaPackages.moonscript ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    install -Dm644 build/progressbar.lua $out/share/mpv/scripts/progressbar.lua
  '';

  passthru.scriptName = "progressbar.lua";

  meta = with lib; {
    description = "A simple progress bar for mpv.";
    homepage = "https://github.com/torque/mpv-progressbar";
    platforms = platforms.all;
    license = licenses.isc;
    maintainers = with maintainers; [ WeraPea ];
  };
}
