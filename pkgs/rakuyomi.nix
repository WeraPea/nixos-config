{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

let
  version = "1.28.3";

  selectSystem =
    attrs:
    attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  arch = selectSystem {
    "x86_64-linux" = "desktop";
    "aarch64-linux" = "aarch64";
  };
  src = fetchurl {
    url = "https://github.com/tachibana-shin/rakuyomi/releases/download/v${version}/rakuyomi-${arch}.zip";
    hash = selectSystem {
      "x86_64-linux" = "sha256-5kTa3BR2El6FQMht1s2Y54sFSDt7223LyEVQgz/wGIc=";
      "aarch64-linux" = "sha256-LLh2sn6yLLrbtVR8+mI19xChfqItF+epgNtmxgJznbE=";
    };
  };
in

stdenv.mkDerivation {
  pname = "rakuyomi";
  inherit version src;

  buildInputs = [ unzip ];
  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir $out
    cp -r rakuyomi.koplugin/* $out/
  '';

  meta = {
    description = "A manga reader plugin for KOReader. (This fork adds new features and backward compatibility)";
    homepage = "https://github.com/tachibana-shin/rakuyomi";
    license = lib.licenses.agpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
