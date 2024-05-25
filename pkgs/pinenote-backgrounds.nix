{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
let
  version = "2021-09-15";
in
stdenvNoCC.mkDerivation {
  pname = "pinenote-backgrounds";
  inherit version;

  pinenotebg1 = fetchurl {
    url = "https://wiki.pine64.org/images/1/19/Pinenotebg1.png";
    hash = "";
  };

  pinenotebg2 = fetchurl {
    url = "https://wiki.pine64.org/images/2/2f/Pinenotebg2.png";
    hash = "";
  };

  pinenotebg3 = fetchurl {
    url = "https://wiki.pine64.org/images/8/85/Pinenotebg3.png";
    hash = "";
  };

  pinenotebg4 = fetchurl {
    url = "https://wiki.pine64.org/images/0/0c/Pinenotebg4.png";
    hash = "";
  };

  change-bg-image = lib.writeShellScriptBin "change-bg-image" ''
    ln -s $out/share/pinenote-backgrounds/Pinenotebg1.png /??? # what path???? https://discord.com/channels/463237927984693259/870707390998282292/1193276401579741214 ioctl python script for this!
  '';

  installPhase = ''
    install -Dm644 ${pinenotebg1} $out/share/pinenote-backgrounds/Pinenotebg1.png
    install -Dm644 ${pinenotebg2} $out/share/pinenote-backgrounds/Pinenotebg2.png
    install -Dm644 ${pinenotebg3} $out/share/pinenote-backgrounds/Pinenotebg3.png
    install -Dm644 ${pinenotebg4} $out/share/pinenote-backgrounds/Pinenotebg4.png
  '';

  meta = with lib; {
    description = "Backgrounds for pinenote.";
    homepage = "https://wiki.pine64.org/wiki/PineNote_Press";
    platforms = platforms.all;
    license = licenses.cc0;
    maintainers = with maintainers; [ WeraPea ];
  };
}
