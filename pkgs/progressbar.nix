{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  pkgs,
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
  buildInputs = [ pkgs.luajitPackages.moonscript ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/mpv/scripts
    cp build/progressbar.lua $out/share/mpv/scripts
    runHook postInstall
  '';

  passthru.scriptName = "progressbar.lua";

  meta = with lib; {
    description = "A simple progress bar for mpv.";
    homepage = "https://github.com/torque/mpv-progressbar";
    platforms = platforms.all;
    maintainers = with maintainers; [ WeraPea ];
  };
}
